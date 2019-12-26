library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;


entity topfft is
    port(
        clk : in std_logic;
        data_in : in std_logic_vector(31 downto 0);
        dv : in std_logic;
        core_says : out std_logic_vector(3 downto 0);
        events : out std_logic_vector(5 downto 0);
        data_out : out std_logic_vector(31 downto 0));
end topfft;


architecture behavioral of topfft is

    signal cntr : std_logic_vector(8 downto 0) := (others => '0');
    signal buffer_in : std_logic_vector(31 downto 0);
    signal buffer_out : std_logic_vector(31 downto 0);
    signal config : std_logic_vector(15 downto 0) := "0100110110101011";
    signal s_axis_data_tlast : std_logic;

    component xfft_0 is
        port(
            aclk : in std_logic;
            s_axis_config_tdata : in std_logic_vector(15 downto 0);
            s_axis_config_tvalid : in std_logic;
            s_axis_config_tready : out std_logic;
            s_axis_data_tdata : in std_logic_vector(31 downto 0);
            s_axis_data_tvalid : in std_logic;
            s_axis_data_tready : out std_logic;
            s_axis_data_tlast : in std_logic;
            m_axis_data_tdata : out std_logic_vector(31 downto 0);
            m_axis_data_tvalid : out std_logic;
            m_axis_data_tready : in std_logic;
            m_axis_data_tlast : out std_logic;
            event_frame_started : out std_logic;
            event_tlast_unexpected : out std_logic;
            event_tlast_missing : out std_logic;
            event_status_channel_halt : out std_logic;
            event_data_in_channel_halt : out std_logic;
            event_data_out_channel_halt : out std_logic);
    end component;

begin

    buffer_in <= data_in;

    gen_tlast : process(clk) begin
        if rising_edge(clk) then
            if cntr = "111111111" then
                s_axis_data_tlast <= '1';
            else
                cntr <= unsigned(cntr) + 1;
            end if;
        end if;
    end process;


    fft : xfft_0
    port map(
        aclk => clk,
        s_axis_config_tdata => config,
        s_axis_config_tvalid => '1',
        s_axis_config_tready => core_says(0),
        s_axis_data_tdata => buffer_in,
        s_axis_data_tvalid => '1',
        s_axis_data_tready => core_says(1),
        s_axis_data_tlast => s_axis_data_tlast,
        m_axis_data_tdata => buffer_out,
        m_axis_data_tvalid => core_says(2),
        m_axis_data_tready => '1',
        m_axis_data_tlast => core_says(3),
        event_frame_started => events(0),
        event_tlast_unexpected => events(1),
        event_tlast_missing => events(2),
        event_status_channel_halt => events(3),
        event_data_in_channel_halt => events(4),
        event_data_out_channel_halt => events(5));

    data_out <= buffer_out;

end behavioral;