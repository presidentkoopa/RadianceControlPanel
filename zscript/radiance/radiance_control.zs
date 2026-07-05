// Radiance Control Panel v0.8 - Final Preset & Logic Bridge
// This script enables the "One-Click" Presets and Flashlight Sync.

class RadianceControlHandler : EventHandler
{
    int lastPreset;

    override void OnRegister()
    {
        lastPreset = CVar.GetCVar("rad_preset", players[consoleplayer]).GetInt();
    }

    override void WorldTick()
    {
        int currentPreset = CVar.GetCVar("rad_preset", players[consoleplayer]).GetInt();
        
        // If the preset has changed, apply the new profile
        if (currentPreset != lastPreset)
        {
            ApplyPreset(currentPreset);
            lastPreset = currentPreset;
        }
    }

    void ApplyPreset(int p)
    {
        switch(p)
        {
            case 1: // Classic RADIANCE (Amber Pulse)
                SetCVarBool("radiance_glow_enabled", true);
                SetCVarInt("vr_visual_regime", 0);
                SetCVarColor("radiance_floor_color", "ff b0 28");
                SetCVarColor("radiance_ceil_color", "30 30 30");
                SetCVarFloat("radiance_floor_intensity", 1.2);
                SetCVarInt("radiance_floor_mode", 1); // Pulse
                SetCVarFloat("radiance_bloom_strength", 1.0);
                SetCVarFloat("radiance_bloomboost_contrast", 140.0);
                break;

            case 2: // Matrix Overdrive (Neon Green)
                SetCVarBool("radiance_glow_enabled", true);
                SetCVarInt("vr_visual_regime", 1); // System Shock (Vector)
                SetCVarColor("radiance_floor_color", "00 ff 33");
                SetCVarColor("radiance_ceil_color", "00 44 11");
                SetCVarColor("radiance_wall_color", "00 ff 33");
                SetCVarFloat("radiance_bloom_strength", 1.8);
                SetCVarFloat("radiance_bloomboost_contrast", 180.0);
                SetCVarFloat("vr_regime_speed", 1.5);
                break;

            case 3: // Digital Abyss (Tron Blue)
                SetCVarBool("radiance_glow_enabled", true);
                SetCVarInt("vr_visual_regime", 2); // Tron (Grid)
                SetCVarColor("radiance_floor_color", "00 88 ff");
                SetCVarColor("radiance_ceil_color", "00 11 44");
                SetCVarFloat("radiance_bloom_strength", 1.4);
                SetCVarFloat("radiance_bloomboost_contrast", 160.0);
                break;

            case 4: // Dead Channel (Noir Grayscale)
                SetCVarBool("radiance_glow_enabled", true);
                SetCVarInt("vr_visual_regime", 5); // Digital Noir
                SetCVarColor("radiance_floor_color", "44 44 44");
                SetCVarColor("radiance_ceil_color", "11 11 11");
                SetCVarFloat("radiance_bloom_strength", 1.0);
                SetCVarFloat("radiance_bloomboost_contrast", 200.0);
                break;

            case 5: // Predator Mode (Thermal)
                SetCVarBool("radiance_glow_enabled", true);
                SetCVarInt("vr_visual_regime", 4); // Thermal
                SetCVarColor("radiance_floor_color", "ff 22 00");
                SetCVarColor("radiance_ceil_color", "00 00 66");
                SetCVarFloat("radiance_bloom_strength", 0.8);
                SetCVarInt("radiance_flashlight_mode", 1); // Thermal Trace
                break;
        }
    }

    // CVar Set Wrappers
    void SetCVarBool(string name, bool val) { let cv = CVar.GetCVar(name, players[consoleplayer]); if(cv) cv.SetBool(val); }
    void SetCVarInt(string name, int val) { let cv = CVar.GetCVar(name, players[consoleplayer]); if(cv) cv.SetInt(val); }
    void SetCVarFloat(string name, float val) { let cv = CVar.GetCVar(name, players[consoleplayer]); if(cv) cv.SetFloat(val); }
    void SetCVarColor(string name, color val) { let cv = CVar.GetCVar(name, players[consoleplayer]); if(cv) cv.SetInt(val); }
}
