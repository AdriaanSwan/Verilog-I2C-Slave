module I2CTest(CLCK, SCL, SDA);

//I2C
input CLCK;
input SCL;
inout SDA;

parameter slaveaddress = 7'b1110010;

//Sample registers to send to requesting device
reg[2:0] valuecnt = 3'b011; //Count of bytes to be sent, send read value twice

//Synch SCL edge to the CPLD clock
reg [2:0] SCLSynch = 3'b000;  
always @(posedge CLCK) 
	SCLSynch <= {SCLSynch[1:0], SCL};
	
wire SCL_posedge = (SCLSynch[2:1] == 2'b01);  
wire SCL_negedge = (SCLSynch[2:1] == 2'b10);  

//Synch SDA to the CPLD clock
reg [2:0] SDASynch = 3'b000;
always @(posedge CLCK) 
	SDASynch <= {SDASynch[1:0], SDA};
	
wire SDA_synched = SDASynch[0] & SDASynch[1] & SDASynch[2];

//Detect start and stop
reg start = 1'b0;
always @(negedge SDA)
	start = SCL;

reg stop = 1'b0;
always @(posedge SDA)
	stop = SCL;

//Set cycle state 
reg incycle = 1'b0;
always @(posedge start or posedge stop)
	if (start)
	begin
		if (incycle == 1'b0)
			incycle = 1'b1;
	end
	else if (stop)
	begin
		if (incycle == 1'b1)
			incycle = 1'b0;	
	end
	
//Address and incomming data handling
reg[7:0] bitcount = 0;
reg[6:0] address = 7'b0000000;
reg[7:0] datain = 8'b00000000;
reg rw = 1'b0;
reg addressmatch = 1'b0;
always @(posedge SCL_posedge or negedge incycle)
	if (~incycle)	
	begin
		//Reset the bit counter at the end of a sequence
		bitcount = 0;
	end
	else
   begin
		bitcount = bitcount + 1;
		
	   //Get the address
		if (bitcount < 8)
			address[7 - bitcount] = SDA_synched;
		
		if (bitcount == 8)
		begin
			rw = SDA_synched;
			addressmatch = (slaveaddress == address) ? 1'b1 : 1'b0;
		end
			
		if ((bitcount > 9) & (~rw))
			//Receive data (currently only one byte)
			datain[17 - bitcount] = SDA_synched;
	end
	
//ACK's and out going data
reg sdadata = 1'bz; 
reg [2:0] currvalue = 	0;
always @(posedge SCL_negedge) 
	//ACK's
	if (((bitcount == 8) | ((bitcount == 17) & ~rw)) & (addressmatch))
	begin
		sdadata = 1'b0;
		currvalue = 0;
	end
	//Data
	else if ((bitcount >= 9) & (rw) & (addressmatch) & (currvalue < valuecnt))
	begin
		//Send Data  
		if (((bitcount - 9) - (currvalue * 9)) == 8)
		begin
			//Release SDA so master can ACK/NAK
			sdadata = 1'bz;
			currvalue = currvalue + 1;
		end
		else sdadata = datain[7 - ((bitcount - 9) - (currvalue * 9))]; //Modify this to send actual data, currently echoing incomming data valuecnt times
	end
	//Nothing (cause nothing tastes like fresca)
	else sdadata = 1'bz;
	
assign SDA = sdadata;

endmodule