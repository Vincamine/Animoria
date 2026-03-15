# 3D Models for AR Species Viewer

## Overview

The AR Species Viewer can display 3D models in augmented reality. Models should be in `.usdz` format (Apple's optimized format for AR).

## Adding 3D Models

### 1. Obtain USDZ Models

**Free Sources:**
- **Sketchfab** (https://sketchfab.com) - Many free 3D models, some downloadable as .usdz
- **TurboSquid** (https://www.turbosquid.com) - Professional models, filter by "USDZ"
- **Apple AR Quick Look Gallery** - Sample models from Apple
- **Poly by Google** (archived) - Historical archive of 3D models

**Convert from other formats:**
- Use Reality Converter (free Mac app from Apple)
- Convert from `.obj`, `.fbx`, `.gltf` to `.usdz`
- Download: https://developer.apple.com/augmented-reality/tools/

### 2. Name Models by Species ID

Models must match the species `id` field:

```
Animoria/Models/3D/
├── island-fox.usdz
├── island-deer-mouse.usdz
├── gopher-snake.usdz
├── island-night-lizard.usdz
├── mule-deer.usdz
├── california-quail.usdz
└── western-fence-lizard.usdz
```

**Naming Convention:**
- File name = `<species.id>.usdz`
- Example: Species with `id = "island-fox"` → `island-fox.usdz`

### 3. Add to Xcode Project

1. Create folder: `Animoria/Models/3D/`
2. Drag `.usdz` files into Xcode
3. **Important:** Check "Copy items if needed" and "Add to targets: Animoria"
4. Models are now embedded in the app bundle

### 4. Model Requirements

**Optimization:**
- **File size:** < 10 MB per model (preferably < 5 MB)
- **Polygon count:** < 100K triangles for mobile
- **Textures:** 2048x2048 max resolution, compressed
- **Materials:** PBR materials (Physically Based Rendering)

**Scale:**
- Real-world scale (1 unit = 1 meter)
- Adjust in Reality Converter if needed
- Fox should be ~0.5m tall, deer ~1m tall, etc.

**Orientation:**
- Model should face +Z axis
- Up should be +Y axis
- Center pivot at ground level

### 5. Testing

**With models:**
- Open AR view from species detail
- Tap surface to place model
- Model appears with textures

**Without models (current):**
- Colored sphere placeholder appears
- Color generated from species ID
- All AR functionality works

## Current Status

**Placeholder Mode:**
- App currently uses colored spheres as placeholders
- ARViewModel automatically checks for `.usdz` files
- Falls back to placeholder if model not found

**Models Needed:**
1. island-fox.usdz
2. island-deer-mouse.usdz
3. gopher-snake.usdz
4. island-night-lizard.usdz
5. mule-deer.usdz
6. california-quail.usdz
7. western-fence-lizard.usdz

## Example: Converting a Model

### Using Reality Converter

1. Download free animal model (`.obj` or `.gltf`)
2. Open Reality Converter
3. Drag model file into window
4. Adjust:
   - Scale (set real-world size)
   - Rotation (face +Z)
   - Materials (enable PBR)
5. Export as `.usdz`
6. Rename to match species ID
7. Add to Xcode project

### Using Command Line (advanced)

```bash
# Convert .obj to .usdz
xcrun usdz_converter input.obj output.usdz

# With options
xcrun usdz_converter input.obj output.usdz \\
  -g "modelName" \\
  -m materials.mtl \\
  -textures textures/
```

## Model Credits

When using models from external sources:
- Respect licensing (CC0, CC-BY, etc.)
- Attribute creators when required
- Commercial use may require paid licenses
- Document credits in `MODEL_CREDITS.md`

## Performance Tips

**Optimize Models:**
- Reduce polygon count in Blender/Maya
- Compress textures (JPEG for diffuse, PNG for alpha)
- Remove hidden faces
- Merge duplicate vertices
- Use LOD (Level of Detail) if needed

**Bundle Size:**
- 7 models × 5 MB = 35 MB app size increase
- Consider on-demand downloads for larger catalogs
- Use `.usdz` compression in Reality Converter

## Troubleshooting

**Model doesn't appear:**
- Check file name matches species ID exactly
- Verify model is added to app target
- Check Xcode console for loading errors

**Model appears black/white:**
- Missing materials/textures
- Re-export with textures embedded
- Check material settings in Reality Converter

**Model too big/small:**
- Adjust scale in Reality Converter
- 1 unit should equal 1 meter
- Test placement in AR to verify size

**App crashes in AR:**
- Model too complex (reduce polygon count)
- Textures too large (compress to 2K or lower)
- Memory issue (test on device, not simulator)

## Future Enhancements

**Animations:**
- Add idle animations (breathing, blinking)
- Walk cycles for mammals
- Flight for birds

**Interactions:**
- Tap to trigger sounds
- Swipe to see behavior
- Info hotspots on model

**Multiple Models:**
- Different poses per species
- Male/female variants
- Juvenile/adult versions

---

**Status:** Placeholder mode active (colored spheres)  
**Next step:** Add first `.usdz` model to test integration
