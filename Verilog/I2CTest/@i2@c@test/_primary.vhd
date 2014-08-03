library verilog;
use verilog.vl_types.all;
entity I2CTest is
    generic(
        slaveaddress    : vl_logic_vector(0 to 6) := (Hi1, Hi1, Hi1, Hi0, Hi0, Hi1, Hi0)
    );
    port(
        CLCK            : in     vl_logic;
        SCL             : in     vl_logic;
        SDA             : inout  vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of slaveaddress : constant is 1;
end I2CTest;
