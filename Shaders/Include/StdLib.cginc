
#ifndef UNITY_POSTFX_STDLIB
#define UNITY_POSTFX_STDLIB

// -----------------------------------------------------------------------------
// API macros


// -----------------------------------------------------------------------------
// Constants

#define HALF_MAX        65504.0 // (2 - 2^-10) * 2^15
#define HALF_MAX_MINUS1 65472.0 // (2 - 2^-9) * 2^15
#define EPSILON         1.0e-4
#define PI              3.14159265359
#define TWO_PI          6.28318530718
#define FOUR_PI         12.56637061436
#define INV_PI          0.31830988618
#define INV_TWO_PI      0.15915494309
#define INV_FOUR_PI     0.07957747155
#define HALF_PI         1.57079632679
#define INV_HALF_PI     0.636619772367

#define FLT_EPSILON     1.192092896e-07 // Smallest positive number, such that 1.0 + FLT_EPSILON != 1.0
#define FLT_MIN         1.175494351e-38 // Minimum representable positive floating-point number
#define FLT_MAX         3.402823466e+38 // Maximum representable floating-point number

// -----------------------------------------------------------------------------
// Compatibility functions

#ifndef INTRINSIC_MINMAX3
float Min3(float a, float b, float c)
{
    return min(min(a, b), c);
}

float2 Min3(float2 a, float2 b, float2 c)
{
    return min(min(a, b), c);
}

float3 Min3(float3 a, float3 b, float3 c)
{
    return min(min(a, b), c);
}

float4 Min3(float4 a, float4 b, float4 c)
{
    return min(min(a, b), c);
}

float Max3(float a, float b, float c)
{
    return max(max(a, b), c);
}

float2 Max3(float2 a, float2 b, float2 c)
{
    return max(max(a, b), c);
}

float3 Max3(float3 a, float3 b, float3 c)
{
    return max(max(a, b), c);
}

float4 Max3(float4 a, float4 b, float4 c)
{
    return max(max(a, b), c);
}
#endif // INTRINSIC_MINMAX3

// https://twitter.com/SebAaltonen/status/878250919879639040
// madd_sat + madd
float FastSign(float x)
{
    return saturate(x * FLT_MAX + 0.5) * 2.0 - 1.0;
}

float2 FastSign(float2 x)
{
    return saturate(x * FLT_MAX + 0.5) * 2.0 - 1.0;
}

float3 FastSign(float3 x)
{
    return saturate(x * FLT_MAX + 0.5) * 2.0 - 1.0;
}

float4 FastSign(float4 x)
{
    return saturate(x * FLT_MAX + 0.5) * 2.0 - 1.0;
}

// Using pow often result to a warning like this
// "pow(f, e) will not work for negative f, use abs(f) or conditionally handle negative values if you expect them"
// PositivePow remove this warning when you know the value is positive and avoid inf/NAN.
float PositivePow(float base, float power)
{
    return pow(max(abs(base), float(FLT_EPSILON)), power);
}

float2 PositivePow(float2 base, float2 power)
{
    return pow(max(abs(base), float2(FLT_EPSILON, FLT_EPSILON)), power);
}

float3 PositivePow(float3 base, float3 power)
{
    return pow(max(abs(base), float3(FLT_EPSILON, FLT_EPSILON, FLT_EPSILON)), power);
}

float4 PositivePow(float4 base, float4 power)
{
    return pow(max(abs(base), float4(FLT_EPSILON, FLT_EPSILON, FLT_EPSILON, FLT_EPSILON)), power);
}

// NaN checker
// /Gic isn't enabled on fxc so we can't rely on isnan() anymore
bool IsNan(float x)
{
    // For some reason the following tests outputs "internal compiler error" randomly on desktop
    // so we'll use a safer but slightly slower version instead :/
    //return (x <= 0.0 || 0.0 <= x) ? false : true;
    return (x < 0.0 || x > 0.0 || x == 0.0) ? false : true;
}

bool AnyIsNan(float2 x)
{
    return IsNan(x.x) || IsNan(x.y);
}

bool AnyIsNan(float3 x)
{
    return IsNan(x.x) || IsNan(x.y) || IsNan(x.z);
}

bool AnyIsNan(float4 x)
{
    return IsNan(x.x) || IsNan(x.y) || IsNan(x.z) || IsNan(x.w);
}

// -----------------------------------------------------------------------------
// Std unity data



// Clamp HDR value within a safe range
float3 SafeHDR(float3 c)
{
    return min(c, HALF_MAX);
}

float4 SafeHDR(float4 c)
{
    return min(c, HALF_MAX);
}

// Decode normals stored in _CameraDepthNormalsTexture
float3 DecodeViewNormalStereo(float4 enc4)
{
    float kScale = 1.7777;
    float3 nn = enc4.xyz * float3(2.0 * kScale, 2.0 * kScale, 0) + float3(-kScale, -kScale, 1);
    float g = 2.0 / dot(nn.xyz, nn.xyz);
    float3 n;
    n.xy = g * nn.xy;
    n.z = g - 1.0;
    return n;
}

// Vertex manipulation
float2 TransformTriangleVertexToUV(float2 vertex)
{
    float2 uv = (vertex + 1.0) * 0.5;
    return uv;
}

// Interleaved gradient function from Jimenez 2014
// http://www.iryoku.com/next-generation-post-processing-in-call-of-duty-advanced-warfare
float GradientNoise(float2 uv, float2 _ScreenParams)
{
    uv = floor(uv * _ScreenParams.xy);
    float f = dot(float2(0.06711056, 0.00583715), uv);
    return frac(52.9829189 * frac(f));
}
inline float Linear01Depth( float z , float4 _ZBufferParams)
{
    return 1.0 / (_ZBufferParams.x * z + _ZBufferParams.y);
}
// Z buffer to linear depth
inline float LinearEyeDepth( float z  , float4 _ZBufferParams)
{
    return 1.0 / (_ZBufferParams.z * z + _ZBufferParams.w);
}


#define TRANSFORM_TEX(tex,name) (tex.xy * name##_ST.xy + name##_ST.zw)

#endif // UNITY_POSTFX_STDLIB
