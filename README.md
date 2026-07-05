
The DoomXR engine's core fragment shader (`shaders/glsl/main.fp`) was reduced to plain rendering math. This mod ships its **own** `shaders/glsl/main.fp` that overrides the engine's copy (last-loaded lump wins) and carries all of the glow / neon / visual-regime code.

- **Engine alone** → renders plainly, no RADIANCE visuals.
- **Engine + this mod** → the full RADIANCE look returns, exactly as before the split.

Also includes the RADIANCE ZScript layer (combos, score bursts, muzzle FX, damage counters, presets/menu) and the bloom-boost post shaders.
