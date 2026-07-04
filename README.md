# Radiance Control Panel

The **GITD ("Glow In The Dark")** visual layer for the DoomXR VR engine, shipped as a standalone mod that loads on top of the engine.

It provides the "party": the glow-in-the-dark glow-spots on walls/floors/ceilings, neon in-air display panels (score/damage readouts, gauges, oscilloscope, skull, lightning), hit-reaction FX, and the full-screen visual **regimes** (Tron, Thermal, System Shock, Blueprint, LSD, and more).

## How it works

The DoomXR engine's core fragment shader (`shaders/glsl/main.fp`) was reduced to plain rendering math. This mod ships its **own** `shaders/glsl/main.fp` that overrides the engine's copy (last-loaded lump wins) and carries all of the glow / neon / visual-regime code.

- **Engine alone** → renders plainly, no GITD visuals.
- **Engine + this mod** → the full GITD look returns, exactly as before the split.

Also includes the GITD ZScript layer (combos, score bursts, muzzle FX, damage counters, presets/menu) and the bloom-boost post shaders.
