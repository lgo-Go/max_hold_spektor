library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity ReadFull is
    Port (
        data: out std_logic_vector (31 downto 0);
        dv: out std_logic;
        rst : in std_logic;
        rfd : in std_logic;
        clk : in std_logic);
end ReadFull;


architecture Behavioral of ReadFull is

    component ReadDataI is
        generic(
            numOfBits : integer := 16;
            file_name : string := "C:\Igor_G\Vivado_projects\max_hold\max_hold_spektor\matlab_function\data2fpgai.dat");
        port(
            data : out std_logic_vector ((numOfBits-1) downto 0);
            dv: out std_logic;
            rst : in std_logic;
            rfd : in std_logic;
            clk : in std_logic);
    end component;

    component ReadDataQ is
        generic(
            numOfBits : integer := 16;
            file_name : string := "C:\Igor_G\Vivado_projects\max_hold\max_hold_spektor\matlab_function\data2fpgaq.dat");
        port(
            data : out std_logic_vector ((numOfBits-1) downto 0);
            dv: out std_logic;
            rst : in std_logic;
            rfd : in std_logic;
            clk : in std_logic);
    end component;

    type input_massive is array (1 downto 0) of std_logic_vector (15 downto 0);
    signal input: input_massive := (others => (others =>'0'));

begin

    ReRead: ReadDataI
    port map (
        dv => dv,
        clk => clk,
        rfd => rfd,
        rst => rst,
        data => input(0));

    ImRead: ReadDataQ
    port map (
        dv => dv,
        clk => clk,
        rfd => rfd,
        rst => rst,
        data => input(1));

    data <= input(1) & input(0);

end Behavioral;