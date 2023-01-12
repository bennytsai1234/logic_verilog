module demo(input clk, reset,
                        input [3:0] input_ones, input [3:0] input_tens, input confirm1,confirm2,
								output reg [3:0] COM, output reg[6:0] seg,
                        output reg[3:0] score, output reg[3:0] remaining_guesses,
                        output reg beep);
 
  divfreq F0(clk, CLK_div);
  reg[3:0] range_max_ones;
  reg[3:0] range_max_tens;
  reg[3:0] range_min_ones;
  reg[3:0] range_min_tens;
  reg [7:0] secret_number;
  // 定義變數來儲存猜測的數字
  reg [7:0] guess;
  reg[31:0] counter1;
  reg[31:0] counter2;
  reg seg_A,seg_B,seg_C,seg_D;
  
  integer flag,flag2,flag3;
  integer rand_num_tens, rand_num_ones;
  
  initial 
		begin 	
			COM[3:0] = 4'b1110;
			flag =0;
			flag2 =0;
			flag3 =0;
			beep = 0;
		end
	always@(seg_A,seg_B,seg_C,seg_D)
		begin
			case({seg_A,seg_B,seg_C,seg_D})
				4'b0000: seg[6:0] = 7'b0000001;
				4'b0001:	seg[6:0] = 7'b1001111;
				4'b0010:	seg[6:0] = 7'b0010010;
				4'b0011:	seg[6:0] = 7'b0000110;
				4'b0100:	seg[6:0] = 7'b1001100;
				4'b0101:	seg[6:0] = 7'b0100100;
				4'b0110:	seg[6:0] = 7'b0100000;
				4'b0111:	seg[6:0] = 7'b0001111;
				4'b1000:	seg[6:0] = 7'b0000000;
				4'b1001:	seg[6:0] = 7'b0000100;
				default: seg[6:0] = 7'b1111111;
			endcase
		end
		
		
	always@(posedge CLK_div)
		begin
			if(COM == 4'b1111)
				COM <= 4'b1110;
			else
				COM[3:0] <= {COM[2:0],1'b1};
		end
  
  always @(posedge clk) 
	begin
		case(COM[3:0])
			4'b1110:	{seg_A,seg_B,seg_C,seg_D} = range_min_tens;
			4'b1101: {seg_A,seg_B,seg_C,seg_D} = range_min_ones;
			4'b1011: {seg_A,seg_B,seg_C,seg_D} = range_max_tens;
			4'b0111: {seg_A,seg_B,seg_C,seg_D} = range_max_ones;
		endcase
	end
 								 
	 
 always @(posedge clk ) begin
  // 產生 0 到 99 的隨機數字
  /*
   counter1 = counter1 +1;
	rand_num_tens = counter1 %10;
   counter2 = counter2 +3;
	rand_num_ones = counter2 %10;
	
	*/
	rand_num_tens = 7;
	rand_num_ones = 7;
  
   if ( reset || flag ==1 ) 
		begin
			flag =0;
			secret_number[3:0] <= rand_num_ones;
			secret_number[7:4] <= rand_num_tens;
			remaining_guesses <= 4'b0010;
			range_max_ones[3:0] <= 4'b1001;
			range_max_tens[3:0] <= 4'b1001;
			range_min_ones[3:0] <= 4'b0000;
			range_min_tens[3:0] <= 4'b0000;
			beep = 0;
		end		
													
	if (confirm1 && ~flag2 ) 
		begin
			guess[3:0] = input_ones;
			flag2=1;
			flag3=0;
		end
	if (confirm2 && ~flag3 ) 
		begin
			guess[7:4] = input_ones;
			flag3=1;
		end												
														
	  // 執行猜測運算
	if (flag2 && flag3 )
		begin
      // 將猜測的數字與隨機數字進行比較
			if (guess > secret_number)
				begin
					range_max_ones <= guess[3:0];
					range_max_tens <= guess[7:4];
				end 
		else if (guess < secret_number) 
				begin
					range_min_ones <= guess[3:0];
					range_min_tens <= guess[7:4];
				end 
		else if (guess == secret_number)
				begin
					score <= score + 1'b1;
					flag = 1;
				end
				
			remaining_guesses <= remaining_guesses - 1'b1;
			flag2=0;
			//flag3=0;
		end
		
		
	if (score == 4'b0101 || remaining_guesses == 4'b0000) 
		begin
			beep =1;
		end 
	else 
		begin
			beep =0;
		end
	if (confirm1 && reset && score >= 4'b0101 && beep ==1)
		begin
			beep =0;
			score <= 4'b0000;
		end
end
  
endmodule


module divfreq (input CLK, output reg CLK_div);
		reg [24:0] Count;
		always@(posedge CLK)
			begin 
				if (Count> 25000) //100hz
					begin 
						Count <=25'b0;
						CLK_div <= ~CLK_div;
					end
				else 
				Count<= Count + 1'b1;
			end
endmodule 

