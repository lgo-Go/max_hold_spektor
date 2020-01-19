library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;


entity tb is
end entity tb;


architecture a of tb is

    signal tbclk : std_logic;
    signal tbdin : std_logic_vector (31 downto 0);
    signal tbout : std_logic_vector (14 downto 0);
    --signal tboutim : std_logic_vector (15 downto 0);
    --signal tboutre : std_logic_vector (15 downto 0);
    signal tbrst : std_logic := '0';
    signal tbrfd : std_logic := '1';
    signal tbdv : std_logic := '1';
    signal tbsign : std_logic := '1';

    signal tb_s_axis_config_tready : std_logic;
    signal tb_s_axis_data_tready : std_logic;
    signal tb_m_axis_data_tvalid : std_logic;
    signal tb_m_axis_data_tlast : std_logic;

    signal tb_event_frame_started : std_logic;
    signal tb_event_tlast_unexpected : std_logic;
    signal tb_event_tlast_missing : std_logic;
    signal tb_event_status_channel_halt : std_logic;
    signal tb_event_data_in_channel_halt : std_logic;
    signal tb_event_data_out_channel_halt : std_logic;

    signal tb_data_i : std_logic_vector(15 downto 0);


    component ReadFull is
        port(
            data : out std_logic_vector (31 downto 0);
            data_i : out std_logic_vector (15 downto 0);
            dv : out std_logic;
            rst : in std_logic;
            rfd : in std_logic;
            clk : in std_logic);
    end component;

    component topfft is
        port(
            clk : in std_logic;
            dv : in std_logic;
            data_in : in std_logic_vector(31 downto 0);
            data_out : out std_logic_vector(14 downto 0);

            s_axis_config_tready : out std_logic;
            s_axis_data_tready : out std_logic;
            m_axis_data_tvalid : out std_logic;
            m_axis_data_tlast : out std_logic;

            event_frame_started : out std_logic;
            event_tlast_unexpected : out std_logic;
            event_tlast_missing : out std_logic;
            event_status_channel_halt : out std_logic;
            event_data_in_channel_halt : out std_logic;
            event_data_out_channel_halt : out std_logic);
    end component;

    component WriteData is
        generic(
            numOfBits : integer;
            file_name : string);
        port(
            clk, dv, sign : in std_logic;
            DataIn : in std_logic_vector ((numofbits-1) downto 0));
    end component;

begin

    generate_clk : process begin
        loop
            tbclk <= '1';
            wait for 5 ns;
            tbclk <= '0';
            wait for 5 ns;
        end loop;
    end process;


    --generate_valid:process (tbclk) begin
    --    if rising_edge(tbclk) then
    --        if tbshifter = "111111111" then
    --            options <= "1100";  
    --        else
    --            tbshifter <= unsigned(tbshifter) + 1;
    --            options <= "1010";
    --        end if;
    --    end if;
    --end process;

    core: topfft
    port map(
        clk => tbclk,
        dv => tbdv,
        data_in => tbdin,
        data_out => tbout,
        s_axis_config_tready => tb_s_axis_config_tready,
        s_axis_data_tready => tb_s_axis_data_tready,
        m_axis_data_tvalid => tb_m_axis_data_tvalid,
        m_axis_data_tlast => tb_m_axis_data_tlast,
        event_frame_started => tb_event_frame_started,
        event_tlast_unexpected => tb_event_tlast_unexpected,
        event_tlast_missing => tb_event_tlast_missing,
        event_status_channel_halt => tb_event_status_channel_halt,
        event_data_in_channel_halt => tb_event_data_in_channel_halt,
        event_data_out_channel_halt => tb_event_data_out_channel_halt);

    read : ReadFull
    port map (
        data_i => tb_data_i,
        dv => tbdv,
        clk => tbclk,
        rfd => tbrfd,
        rst => tbrst,
        data => tbdin);

    --tboutim <= tbout(31 downto 16);
    --tboutre <= tbout(15 downto 0);

    write : WriteData
    generic map(
            numofbits => 15,
            file_name => "C:\Igor_G\Vivado_projects\max_hold\max_hold_spektor\matlab_function\maxholdfromfpga.dat")
    port map (
        clk => tbclk,
        dv => tbdv,
        sign => tbsign,
        DataIn => tbout);

    --write2 : WriteData
    --generic map(
    --        numofbits => 16,
    --        file_name => "C:\Igor_G\Vivado_projects\max_hold\max_hold_spektor\matlab_function\datafromfpgaq.dat")
    --port map (
    --    clk => tbclk,
    --    dv => tbdv,
    --    sign => tbsign,
    --    DataIn => tboutim);

    --event_frame_started <= tbconditions(4);
    --event_tlast_unexpected <= tbconditions(5);
    --event_tlast_missing <= tbconditions(6);
    --event_status_channel_halt <= tbconditions(7);
    --event_data_in_channel_halt <= tbconditions(8);
    --event_data_out_channel_halt <= tbconditions(9);

end a;