library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
 

entity tb is
end entity tb;


architecture a of tb is

    signal tbdin : std_logic_vector (31 downto 0);
    signal tbout : std_logic_vector (31 downto 0);
    signal tboutim : std_logic_vector (15 downto 0);
    signal tboutre : std_logic_vector (15 downto 0);
    signal tbclk : std_logic;
    signal tbrst : std_logic := '0';
    signal tbrfd : std_logic := '1';
    signal tbdv : std_logic := '1';
    signal tbsign : std_logic := '1';
    signal s_axis_data_tvalid : std_logic := '0';
    signal s_axis_data_tready : std_logic := '1';
    signal options : std_logic_vector(3 downto 0) := (others=> '0');
    signal tbshifter : std_logic_vector(8 downto 0) := "000000000";
    signal tbconditions : std_logic_vector(15 downto 0) := "0000000000000000";
    signal event_frame_started : std_logic;
    signal event_tlast_unexpected :  std_logic;
    signal event_tlast_missing : std_logic;
    signal event_status_channel_halt : std_logic;
    signal event_data_in_channel_halt : std_logic;
    signal event_data_out_channel_halt : std_logic;


    component readfull is
    --generic( 
    --numofbits : integer:=16;
    --file_name : string 
        port(
            data : out std_logic_vector (31 downto 0);
            dv : out std_logic;
            rst : in std_logic;
            rfd : in std_logic
            clk : in std_logic);
    end component;

    component topfft is
        port(
            data_in : in std_logic_vector(31 downto 0);
            clk : in std_logic;
            dv : in std_logic;
            options : in std_logic_vector(3 downto 0);
            shifter : in std_logic_vector(9 downto 0);
            s_axis_data_tvalid : in std_logic := '0';
            s_axis_data_tready : out std_logic := '0';
            conditions : out std_logic_vector(15 downto 0);
            tvalid : in std_logic := '1';
            data_out : out std_logic_vector(31 downto 0));
    end component;

    component writedata is
        generic(
            numofbits : integer := 16;
            file_name : string := "d:\цуимп курсач\max_hold_spektor\matlab_function\datafromfpgai.dat");
        port( 
            clk, dv, sign : in std_logic;
            datain : in std_logic_vector ((numofbits-1) downto 0));
    end component;

begin

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
            if tbshifter = "111111111" then
                options <= "1100";  
            else
                tbshifter <= unsigned(tbshifter) + 1;
                options <= "1010";
            end if;
        end if;
    end process;

    core: topfft
    port map(
        options => options,
        data_in => tbdin,
        clk => tbclk,
        dv => tbdv,
         --s_axis_data_tvalid =>s_axis_data_tvalid ,
         --s_axis_data_tready => s_axis_data_tready,
        conditions => tbconditions,
        shifter => tbshifter,
        tvalid => tbdv,
        data_out => tbout);

    read : readfull
    port map (
        dv => tbdv,
        clk => tbclk,
        rfd => tbrfd,
        rst => tbrst,
        data => tbdin);

    tboutim <= tbout(31 downto 16);
    tboutre <= tbout(15 downto 0);

    write : writedata
    generic map(
            numofbits => 16,
            file_name => "d:\цуимп курсач\max_hold_spektor\matlab_function\datafromfpgai.dat")
    port map (
        clk => tbclk,
        dv => tbdv,
        sign => tbsign,
        datain => tboutim);

    write2 : writedata
    generic map(
            numofbits => 16,
            file_name => "d:\цуимп курсач\max_hold_spektor\matlab_function\datafromfpgaq.dat")
    port map (
        clk => tbclk,
        dv => tbdv,
        sign => tbsign,
        datain => tboutre);

    event_frame_started <= tbconditions(4);
    event_tlast_unexpected <= tbconditions(5);
    event_tlast_missing <= tbconditions(6);
    event_status_channel_halt <= tbconditions(7);
    event_data_in_channel_halt <= tbconditions(8);
    event_data_out_channel_halt <= tbconditions(9);

end a;