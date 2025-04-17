module sine_wave (
    input wire clk,
    input wire rst,
    output reg [7:0] dac_out
);
    reg [7:0] addr;
    reg [7:0] sine_lut [0:255];

    initial begin
        sine_lut[0]=128;  sine_lut[1]=131;  sine_lut[2]=134;  sine_lut[3]=137;
        sine_lut[4]=140;  sine_lut[5]=143;  sine_lut[6]=146;  sine_lut[7]=149;
        sine_lut[8]=152;  sine_lut[9]=156;  sine_lut[10]=159; sine_lut[11]=162;
        sine_lut[12]=165; sine_lut[13]=168; sine_lut[14]=171; sine_lut[15]=174;
        sine_lut[16]=177; sine_lut[17]=180; sine_lut[18]=183; sine_lut[19]=186;
        sine_lut[20]=188; sine_lut[21]=191; sine_lut[22]=194; sine_lut[23]=197;
        sine_lut[24]=199; sine_lut[25]=202; sine_lut[26]=204; sine_lut[27]=207;
        sine_lut[28]=209; sine_lut[29]=211; sine_lut[30]=213; sine_lut[31]=216;
        sine_lut[32]=218; sine_lut[33]=220; sine_lut[34]=222; sine_lut[35]=224;
        sine_lut[36]=225; sine_lut[37]=227; sine_lut[38]=229; sine_lut[39]=230;
        sine_lut[40]=232; sine_lut[41]=233; sine_lut[42]=234; sine_lut[43]=236;
        sine_lut[44]=237; sine_lut[45]=238; sine_lut[46]=239; sine_lut[47]=240;
        sine_lut[48]=241; sine_lut[49]=241; sine_lut[50]=242; sine_lut[51]=243;
        sine_lut[52]=243; sine_lut[53]=244; sine_lut[54]=244; sine_lut[55]=244;
        sine_lut[56]=245; sine_lut[57]=245; sine_lut[58]=245; sine_lut[59]=245;
        sine_lut[60]=245; sine_lut[61]=244; sine_lut[62]=244; sine_lut[63]=244;
        sine_lut[64]=243; sine_lut[65]=243; sine_lut[66]=242; sine_lut[67]=241;
        sine_lut[68]=241; sine_lut[69]=240; sine_lut[70]=239; sine_lut[71]=238;
        sine_lut[72]=237; sine_lut[73]=236; sine_lut[74]=234; sine_lut[75]=233;
        sine_lut[76]=232; sine_lut[77]=230; sine_lut[78]=229; sine_lut[79]=227;
        sine_lut[80]=225; sine_lut[81]=224; sine_lut[82]=222; sine_lut[83]=220;
        sine_lut[84]=218; sine_lut[85]=216; sine_lut[86]=213; sine_lut[87]=211;
        sine_lut[88]=209; sine_lut[89]=207; sine_lut[90]=204; sine_lut[91]=202;
        sine_lut[92]=199; sine_lut[93]=197; sine_lut[94]=194; sine_lut[95]=191;
        sine_lut[96]=188; sine_lut[97]=186; sine_lut[98]=183; sine_lut[99]=180;
        sine_lut[100]=177; sine_lut[101]=174; sine_lut[102]=171; sine_lut[103]=168;
        sine_lut[104]=165; sine_lut[105]=162; sine_lut[106]=159; sine_lut[107]=156;
        sine_lut[108]=152; sine_lut[109]=149; sine_lut[110]=146; sine_lut[111]=143;
        sine_lut[112]=140; sine_lut[113]=137; sine_lut[114]=134; sine_lut[115]=131;
        sine_lut[116]=128; sine_lut[117]=124; sine_lut[118]=121; sine_lut[119]=118;
        sine_lut[120]=115; sine_lut[121]=112; sine_lut[122]=109; sine_lut[123]=106;
        sine_lut[124]=103; sine_lut[125]=99; sine_lut[126]=96; sine_lut[127]=93;
        sine_lut[128]=90; sine_lut[129]=87; sine_lut[130]=84; sine_lut[131]=81;
        sine_lut[132]=78; sine_lut[133]=75; sine_lut[134]=72; sine_lut[135]=69;
        sine_lut[136]=67; sine_lut[137]=64; sine_lut[138]=61; sine_lut[139]=58;
        sine_lut[140]=56; sine_lut[141]=53; sine_lut[142]=51; sine_lut[143]=48;
        sine_lut[144]=46; sine_lut[145]=44; sine_lut[146]=42; sine_lut[147]=39;
        sine_lut[148]=37; sine_lut[149]=35; sine_lut[150]=33; sine_lut[151]=31;
        sine_lut[152]=30; sine_lut[153]=28; sine_lut[154]=26; sine_lut[155]=25;
        sine_lut[156]=23; sine_lut[157]=22; sine_lut[158]=21; sine_lut[159]=19;
        sine_lut[160]=18; sine_lut[161]=17; sine_lut[162]=16; sine_lut[163]=15;
        sine_lut[164]=14; sine_lut[165]=14; sine_lut[166]=13; sine_lut[167]=12;
        sine_lut[168]=12; sine_lut[169]=11; sine_lut[170]=11; sine_lut[171]=11;
        sine_lut[172]=10; sine_lut[173]=10; sine_lut[174]=10; sine_lut[175]=10;
        sine_lut[176]=10; sine_lut[177]=11; sine_lut[178]=11; sine_lut[179]=11;
        sine_lut[180]=12; sine_lut[181]=12; sine_lut[182]=13; sine_lut[183]=14;
        sine_lut[184]=14; sine_lut[185]=15; sine_lut[186]=16; sine_lut[187]=17;
        sine_lut[188]=18; sine_lut[189]=19; sine_lut[190]=21; sine_lut[191]=22;
        sine_lut[192]=23; sine_lut[193]=25; sine_lut[194]=26; sine_lut[195]=28;
        sine_lut[196]=30; sine_lut[197]=31; sine_lut[198]=33; sine_lut[199]=35;
        sine_lut[200]=37; sine_lut[201]=39; sine_lut[202]=42; sine_lut[203]=44;
        sine_lut[204]=46; sine_lut[205]=48; sine_lut[206]=51; sine_lut[207]=53;
        sine_lut[208]=56; sine_lut[209]=58; sine_lut[210]=61; sine_lut[211]=64;
        sine_lut[212]=67; sine_lut[213]=69; sine_lut[214]=72; sine_lut[215]=75;
        sine_lut[216]=78; sine_lut[217]=81; sine_lut[218]=84; sine_lut[219]=87;
        sine_lut[220]=90; sine_lut[221]=93; sine_lut[222]=96; sine_lut[223]=99;
        sine_lut[224]=103; sine_lut[225]=106; sine_lut[226]=109; sine_lut[227]=112;
        sine_lut[228]=115; sine_lut[229]=118; sine_lut[230]=121; sine_lut[231]=124;
        sine_lut[232]=128; sine_lut[233]=131; sine_lut[234]=134; sine_lut[235]=137;
        sine_lut[236]=140; sine_lut[237]=143; sine_lut[238]=146; sine_lut[239]=149;
        sine_lut[240]=152; sine_lut[241]=156; sine_lut[242]=159; sine_lut[243]=162;
        sine_lut[244]=165; sine_lut[245]=168; sine_lut[246]=171; sine_lut[247]=174;
        sine_lut[248]=177; sine_lut[249]=180; sine_lut[250]=183; sine_lut[251]=186;
        sine_lut[252]=188; sine_lut[253]=191; sine_lut[254]=194; sine_lut[255]=197;
    end

    always @(posedge clk or posedge rst) begin
        if (rst)
            addr <= 0;
        else
            addr <= addr + 1;
    end

    always @(posedge clk) begin
        dac_out <= sine_lut[addr];
    end
endmodule
