#ifndef __VOXELLIGHT_INCLUDE__
#define __VOXELLIGHT_INCLUDE__

#define XRES 32
#define YRES 16
#define ZRES 64
#define VOXELZ 64
#define MAXLIGHTPERCLUSTER 128
#define FROXELRATE 1.35
#define CLUSTERRATE 1.5
#define VOXELSIZE uint3(XRES, YRES, ZRES)

struct LightCommand{
    float3 direction;
	int shadowmapIndex;
	//
	float3 lightColor;
	uint lightType;
	//Align
	float3 position;
	float spotAngle;
	//Align
	float shadowSoftValue;
	float shadowBias;
	float shadowNormalBias;
	float range;
	//Align
	float spotRadius;
	float3 __align;
};
inline uint GetIndex(uint3 id, const uint3 size, const int multiply){
    const uint3 multiValue = uint3(1, size.x, size.x * size.y) * multiply;
    return dot(id, multiValue);
}

float3 CalculateLocalLight(
	float2 uv, 
	float4 WorldPos, 
	float linearDepth, 
	float3 WorldNormal,
	float3 ViewDir, 
	float cameraNear, 
	float lightFar,
	StructuredBuffer<uint> lightIndexBuffer,
	StructuredBuffer<LightCommand> lightBuffer)
{
	float ShadowTrem = 0;
	float3 ShadingColor = 0;
	float rate = pow(max(0, (linearDepth - cameraNear) /(lightFar - cameraNear)), 1.0 / CLUSTERRATE);
    if(rate > 1) return 0;
	uint3 voxelValue = uint3((uint2)(uv * float2(XRES, YRES)), (uint)(rate * ZRES));
	uint sb = GetIndex(voxelValue, VOXELSIZE, (MAXLIGHTPERCLUSTER + 1));
	uint c;

	float2 JitterSpot = uv;
	uint2 LightIndex = uint2(sb + 1, lightIndexBuffer[sb]);	// = uint2(sb + 1, _PointLightIndexBuffer[sb]);
	
	
	[loop]
	for (c = LightIndex.x; c < LightIndex.y; c++)
	{
		LightCommand lightCommand = lightBuffer[lightIndexBuffer[c]];
		ShadingColor += lightCommand.lightColor;
	}
	return ShadingColor;
}

#endif