#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

/// Liquid highlight swept once across the live lockplate.
[[ stitchable ]] half4 chromeSweep(float2 position, SwiftUI::Layer layer, float2 size, float progress) {
    half4 color = layer.sample(position);
    float span = max(size.x, 1.0);
    float x = position.x / span;
    float band = exp(-pow((x - progress) * 8.0, 2.0));
    half3 metal = half3(0.98, 0.86, 1.0);
    half3 mixed = mix(color.rgb, metal, half(band) * 0.85h * color.a);
    return half4(mixed, color.a);
}
