// 極座標変換


float2 ConvertToPolarCoord(float2 uv){
	float2 coord0 = (uv*2.0)-1.0;
    float theta = frac(atan2(coord0.g,coord0.r)/6.28318530718);
    return float2(theta,distance(uv,float2(0.5,0.5))*2.0);
}