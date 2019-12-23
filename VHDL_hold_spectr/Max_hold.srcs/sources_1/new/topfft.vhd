library IEEE; 
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all; 
entity topfft is 
port( 
data_in: in std_logic_vector(31 downto 0); 
clk: in std_logic; 
dv: in std_logic; 
s_axis_data_tvalid :in std_logic:='0'; 
s_axis_data_tready : out std_logic:='0'; 
options: in std_logic_vector(3 downto 0);
shifter: in std_logic_vector(11 downto 0);
tvalid: in std_logic:='1'; 
data_out: out std_logic_vector(31 downto 0); 
conditions: out std_logic_vector(15 downto 0)); 

end topfft; 

architecture Behavioral of topfft is 
type sample is array(511 downto 0) of std_logic_vector (31 downto 0);
signal ish: sample;
signal sr: sample;
signal cntr: std_logic_vector(9 downto 0);
signal last : std_logic:='0';
signal buffer_in : std_logic_vector(31 downto 0);
signal buffer_out : std_logic_vector(31 downto 0);
signal config : std_logic_vector(15 downto 0):=("0000000000000000");
signal cond: std_logic_vector(15 downto 0):=("0000000000000000");
component xfft_0 is 
PORT (
    aclk : IN STD_LOGIC:='0';
    s_axis_config_tdata : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    s_axis_config_tvalid : IN STD_LOGIC;
    s_axis_config_tready : OUT STD_LOGIC;
    s_axis_data_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    s_axis_data_tvalid : IN STD_LOGIC;
    s_axis_data_tready : OUT STD_LOGIC;
    s_axis_data_tlast : IN STD_LOGIC;
    m_axis_data_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    m_axis_data_tvalid : OUT STD_LOGIC;
    m_axis_data_tready : IN STD_LOGIC:='1';
    m_axis_data_tlast : OUT STD_LOGIC;
    event_frame_started : OUT STD_LOGIC;
    event_tlast_unexpected : OUT STD_LOGIC;
    event_tlast_missing : OUT STD_LOGIC;
    event_status_channel_halt : OUT STD_LOGIC;
    event_data_in_channel_halt : OUT STD_LOGIC;
    event_data_out_channel_halt : OUT STD_LOGIC
  );
end component; 

begin 
process(clk) begin 
if rising_edge(clk) then 
    if cntr = "111111111" then
    cntr<="111111111"; 
      buffer_in <= (others => '0');
      else cntr <= unsigned(cntr) + 1;
buffer_in<=data_in;
end if;
end if;
end process;

fft:xfft_0
port map(  
    aclk=>clk,
      s_axis_config_tdata=>config,
      s_axis_config_tvalid=>'0',
    s_axis_config_tready=>open,
      s_axis_data_tdata=>buffer_in,
      s_axis_data_tvalid=>'1',
    s_axis_data_tready =>s_axis_data_tready,
      s_axis_data_tlast=>options(2),
      m_axis_data_tdata=>buffer_out,
    m_axis_data_tvalid=>cond(2),
      m_axis_data_tready=>options(3),
    m_axis_data_tlast=>cond(3),
    event_frame_started=>cond(4),
    event_tlast_unexpected=>cond(5),
    event_tlast_missing=>cond(6),
    event_status_channel_halt=>cond(7),
    event_data_in_channel_halt=>cond(8),
    event_data_out_channel_halt=>cond(9)
);
--fft:xfft_0
--port map( 
--    aclk=>clk,
--      s_axis_config_tdata=>config,
--      s_axis_config_tvalid=>options(0),
--    s_axis_config_tready=>cond(0),
--      s_axis_data_tdata=>buffer_in,
--      s_axis_data_tvalid=>s_axis_data_tvalid,
--    s_axis_data_tready =>s_axis_data_tready,
--      s_axis_data_tlast=>options(2),
--      m_axis_data_tdata=>buffer_out,
--    m_axis_data_tvalid=>cond(2),
--      m_axis_data_tready=>options(3),
--    m_axis_data_tlast=>cond(3),
--    event_frame_started=>cond(4),
--    event_tlast_unexpected=>cond(5),
--    event_tlast_missing=>cond(6),
--    event_status_channel_halt=>cond(7),
--    event_data_in_channel_halt=>cond(8),
--    event_data_out_channel_halt=>cond(9)
--);

srav: for i in 0 to 511 generate
sam: sravnenie
port map(ish(i)<= buffer_out,хз блять как сравнить тут эту хуету



data_out<=buffer_out;
conditions<=cond;

end Behavioral;