// ============================================================================
//  RADIANCE_ComboMeter -- a cumulative DAMAGE counter drawn with the SHADER digits
//  (wipeType 13: the SAME engine glow-number the floor kill counter uses), riding
//  each monster. Keep damaging it -> the number CLIMBS; stop too long -> the chain
//  breaks, the number fades, and the PEAK is banked into the score system.
//
//  This is the RADIANCE glow SHADER, not sprites. It draws on the floor beneath the
//  monster, tracking it. It runs in TANDEM with HF_DamNum (the per-hit pops) --
//  two separate systems, on purpose. VR-safe (flat surface glow like every RADIANCE FX).
//
//  Score tie-in: on bank it fires the `hf_combo_bank` netevent (player, points,
//  peak). HF's score brain (HF_ScoreHandler) receives it and awards the points --
//  decoupled, so RADIANCE never hard-depends on HF being loaded.
//
//  Cvars: radiance_combo_enabled, radiance_combo_target (0 all / 1 champions / 2 bosses),
//         radiance_combo_fade (chain-break window, tics), radiance_combo_radius,
//         radiance_combo_scoremul, radiance_combo_color (0 cyan / 1 gold / 2 red / 3 green).
// ============================================================================

class RADIANCE_ComboTag : Actor
{
	int total;      // cumulative damage this chain
	int peak;       // highest the chain reached (what we bank)
	int chain;      // tics since the last hit (breaks at radiance_combo_fade)
	int age;        // for the open animation
	int owner;      // player number that built this chain (for scoring)
	bool banked;
	Vector3 burstAt;   // last-known spot above the monster's head, where the score burst spawns

	Default { +NOINTERACTION +NOGRAVITY +NOBLOCKMAP +DONTSPLASH +NOTONAUTOMAP; RenderStyle "None"; }
	States { Spawn: TNT1 A 1; Loop; }

	static int    CInt(string n, int d)    { CVar c = CVar.FindCVar(n); return c ? c.GetInt()   : d; }
	static double CFlt(string n, double d) { CVar c = CVar.FindCVar(n); return c ? c.GetFloat() : d; }

	void AddDamage(int dmg, int pn)
	{
		if (dmg <= 0) return;
		total += dmg;
		if (total > peak) peak = total;
		chain = 0;          // refresh the chain
		owner = pn;
	}

	override void Tick()
	{
		Super.Tick();
		age++;
		Actor mon = master;
		if (!mon || mon.health <= 0) { Bank(); return; }     // monster gone -> bank the chain

		int fadeAfter = max(5, CInt("radiance_damage_numbers_window", 15));
		chain++;
		if (chain > fadeAfter) { Bank(); return; }            // chain broke -> bank

		burstAt = (mon.pos.x, mon.pos.y, mon.pos.z + mon.height + 30.0);   // where the score burst will appear

		// draw the running total with the shader, on a PANEL floating above the monster's
		// head, FACING the player (the in-air glow-billboard, not the floor disc).
		int shown = clamp(total, 0, 99999);
		int cidx  = clamp(CInt("radiance_combo_color", 1), 0, 3);   // default gold

		// neon colour per cidx (cyan / gold / red / green)
		int br, bg, bb;
		CVar cc = CVar.FindCVar("radiance_damage_numbers_color");
		if (cc)
		{
			Color c = cc.GetInt();
			br = c.r; bg = c.g; bb = c.b;
		}
		else if (cidx == 0) { br =  60; bg = 210; bb = 255; }   // cyan
		else if (cidx == 1) { br = 255; bg = 196; bb =  60; }   // gold
		else if (cidx == 2) { br = 255; bg =  60; bb =  60; }   // red
		else                { br =  70; bg = 255; bb = 110; }   // green

		double prog = (age < 10) ? double(age) / 10.0 : 1.0;    // panel pops in
		// dim as the chain ages toward breaking -- a visible "hurry, it's slipping" cue
		double heat = 1.0 - clamp(double(chain) / double(fadeAfter), 0.0, 1.0) * 0.55;
		double bright = clamp(prog * heat, 0.20, 1.0);
		Color col = Color(255, int(br * bright), int(bg * bright), int(bb * bright));

		double rad   = 22.0;                                    // panel half-size
		double headZ = mon.pos.z + mon.height + 16.0;          // float just above the head

		int style = CInt("radiance_combo_style", 0);
		if (style == 0 || style == 2)
		{
			level.AddGlowPanel(col, rad, mon.pos.x, mon.pos.y, headZ, 6313,
				1.0, 0.0, 0.0, shown);                             // wipeType 6313 = digit panel, font index 63 (pacfont); counter = the number
		}
		if (style == 1 || style == 2)
		{
			int packn = shown + cidx * 131072;
			Color floorCol = Color(255, (packn >> 16) & 255, (packn >> 8) & 255, packn & 255);
			double floorRad = CFlt("radiance_combo_radius", 56.0);
			level.AddGlowSpotWiped(floorCol, floorRad, mon.pos.x, mon.pos.y, 13, prog, 1.0, 0.0, 1);
		}
	}

	void Bank()
	{
		if (!banked && peak > 0)
		{
			banked = true;
			double mul = CFlt("radiance_combo_scoremul", 1.0);
			int pts = int(peak * mul);
			if (pts > 0)
				EventHandler.SendNetworkEvent("hf_combo_bank", owner, pts, peak);

			// fire the kill-reward score display at the spot the chain ended
			Vector3 sp = (burstAt.x == 0 && burstAt.y == 0 && burstAt.z == 0) ? pos : burstAt;
			RADIANCE_ScoreBurst b = RADIANCE_ScoreBurst(Actor.Spawn("RADIANCE_ScoreBurst", sp));
			if (b) { b.burstScore = peak; b.owner = owner; b.maxlife = 90; }
		}
		Destroy();
	}
}

class RADIANCE_ComboHandler : EventHandler
{
	static int CInt(string n, int d) { CVar c = CVar.FindCVar(n); return c ? c.GetInt() : d; }

	override void WorldThingDamaged(WorldEvent e)
	{
		Actor mon = e.Thing;
		if (!mon || !mon.bIsMonster || mon.health <= 0 || e.Damage <= 0) return;

		int pn = PlayerFrom(e);
		if (pn < 0) return;

		int mode = CInt("radiance_damage_numbers_mode", 0);
		if (mode == 1) // Per-Shot Numbers
		{
			RADIANCE_DamPop.Fire(mon.pos + (0, 0, mon.height * 0.6), e.Damage);
		}
		else if (mode == 2) // Cumulative Tracking
		{
			RADIANCE_ComboTag tag = FindTag(mon);
			if (!tag)
			{
				tag = RADIANCE_ComboTag(Actor.Spawn("RADIANCE_ComboTag", mon.pos));
				if (tag) 
				{
					tag.master = mon;
					tag.burstAt = (mon.pos.x, mon.pos.y, mon.pos.z + mon.height + 30.0);
				}
			}
			if (tag) tag.AddDamage(e.Damage, pn);
		}

		// Keep the old combo logic running for scoring if enabled, but independent of popups
		if (CInt("radiance_combo_enabled", 1) && mode != 2)
		{
			RADIANCE_ComboTag tag = FindTag(mon);
			if (!tag && PassesFilter(mon))
			{
				tag = RADIANCE_ComboTag(Actor.Spawn("RADIANCE_ComboTag", mon.pos));
				if (tag) 
				{
					tag.master = mon;
					tag.burstAt = (mon.pos.x, mon.pos.y, mon.pos.z + mon.height + 30.0);
				}
			}
			if (tag) tag.AddDamage(e.Damage, pn);
		}
	}

	int PlayerFrom(WorldEvent e)
	{
		Actor s = e.DamageSource;
		if (s && s.player) return s.PlayerNumber();
		if (e.Inflictor && e.Inflictor.target && e.Inflictor.target.player)
			return e.Inflictor.target.PlayerNumber();
		return -1;
	}

	bool PassesFilter(Actor mon)
	{
		int f = CInt("radiance_combo_target", 0);     // 0 all, 1 champions, 2 bosses
		if (f <= 0) return true;
		if (f == 2) return mon.bBoss;
		// champions: HF tags them elsewhere; until that's wired, treat bosses as the
		// "elite" set so the filter does SOMETHING useful in the meantime.
		return mon.bBoss;
	}

	RADIANCE_ComboTag FindTag(Actor mon)
	{
		ThinkerIterator it = ThinkerIterator.Create("RADIANCE_ComboTag");
		RADIANCE_ComboTag t;
		while (t = RADIANCE_ComboTag(it.Next()))
			if (t.master == mon) return t;
		return null;
	}
}
