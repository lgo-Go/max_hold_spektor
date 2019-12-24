LIBRARY ieee; 
USE ieee.std_logic_1164.all;
 USE ieee.std_logic_arith.all;
 
ENTITY tb IS 
END ENTITY tb; 

ARCHITECTURE a OF tb IS 

signal tbdin : STD_LOGIC_VECTOR (31 downto 0); 
signal tbout : STD_LOGIC_VECTOR (31 downto 0); 
signal tboutIm : STD_LOGIC_VECTOR (15 downto 0);
signal tboutRe : STD_LOGIC_VECTOR (15 downto 0);  
signal tbclk : std_logic; 
signal tbrst : std_logic:='0'; 
signal tbrfd : std_logic:='1'; 
signal tbdv : std_logic:='1'; 
signal tbsign : std_logic:='1'; 
signal s_axis_data_tvalid : std_logic:='0'; 
signal s_axis_data_tready : std_logic:='1'; 
signal options: std_logic_vector(3 downto 0):=(others=> '0');
signal tbshifter:std_logic_vector(8 downto 0):="000000000";
signal tbconditions:std_logic_vector(15 downto 0):="0000000000000000";
signal    event_frame_started :STD_LOGIC;
signal    event_tlast_unexpected :  STD_LOGIC;
signal    event_tlast_missing : STD_LOGIC;
signal    event_status_channel_halt : STD_LOGIC;
signal    event_data_in_channel_halt : STD_LOGIC;
signal    event_data_out_channel_halt : STD_LOGIC;


component ReadFull is 
--generic( 
--numOfBits : integer:=16;
--file_name : string 
 Port (
data: out STD_LOGIC_VECTOR (31 downto 0); 
dv: out std_logic; 
rst : in std_logic; 
rfd : in std_logic;
clk : in std_logic);  
end component; 

component topfft is
port( 
data_in: in std_logic_vector(31 downto 0); 
clk: in std_logic; 
dv: in std_logic;
options: in std_logic_vector(3 downto 0);
shifter: in std_logic_vector(9 downto 0);
s_axis_data_tvalid :in std_logic:='0'; 
s_axis_data_tready : out std_logic:='0'; 
conditions: out std_logic_vector(15 downto 0);
tvalid: in std_logic:='1'; 
data_out: out std_logic_vector(31 downto 0)); 
end component;

component WriteData IS 
generic( 
numOfBits: integer:=16;
file_name : string := "D:\÷”»Ãœ  ”–—¿◊\max_hold_spektor\matlab_function\DataFromfpgaI.dat"); 
port( 
clk,dv,sign : in std_logic; 
DataIn : in std_logic_vector ((numOfBits-1) downto 0)); 
end component; 



BEGIN 



generate_clk : process begin 
loop 
tbclk <= '1'; 
wait for 25 ns; 
tbclk <= '0'; 
wait for 25 ns; 
end loop; 
end process; 


generate_valid:process (tbclk) begin 
    if rising_edge(tbclk) then
        if tbshifter="111111111" then
    options<="1100";  
     else         
tbshifter<=unsigned(tbshifter) + 1; 
options <= "1010";

          
 end if;
end if;
end process; 
 

core: topfft
port map( 
options=>options,
data_in=>tbdin, 
clk=>tbclk,
dv=>tbdv,
 --s_axis_data_tvalid =>s_axis_data_tvalid ,
 --s_axis_data_tready => s_axis_data_tready,
conditions=>tbconditions,
shifter=>tbshifter,
tvalid=>tbdv,
data_out=>tbout); 

read : ReadFull 
port map ( 
dv => tbdv, 
clk => tbclk, 
rfd => tbrfd, 
rst => tbrst, 
data => tbdin); 



tboutIm<=tbout(31 downto 16);
tboutRe<=tbout(15 downto 0);
write : WriteData
generic map( 
        numOfBits => 16,
        file_name => "D:\÷”»Ãœ  ”–—¿◊\max_hold_spektor\matlab_function\DataFromfpgaI.dat")
port map ( 
clk => tbclk, 
dv => tbdv, 
sign => tbsign, 
DataIn => tboutIm); 

write2 : WriteData
generic map( 
        numOfBits => 16,
        file_name => "D:\÷”»Ãœ  ”–—¿◊\max_hold_spektor\matlab_function\DataFromfpgaQ.dat")
port map ( 
clk => tbclk, 
dv => tbdv, 
sign => tbsign, 
DataIn => tboutRe); 
    event_frame_started<=tbconditions(4);
    event_tlast_unexpected<=tbconditions(5);
    event_tlast_missing<=tbconditions(6);
    event_status_channel_halt<=tbconditions(7);
    event_data_in_channel_halt<=tbconditions(8);
    event_data_out_channel_halt<=tbconditions(9);
END a;