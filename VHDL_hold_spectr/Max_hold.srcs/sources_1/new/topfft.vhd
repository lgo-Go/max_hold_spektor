library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;


entity topfft is
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
end topfft;


architecture behavioral of topfft is

    --type RAM is array (511 downto 0) of std_logic_vector (14 downto 0);
    --signal MAXhold : RAM := (others => (others => '0'));

    signal memory_d : std_logic_vector(14 downto 0) := (others => '0');
    signal memory_dpo : std_logic_vector(14 downto 0) := (others => '0');

    signal abs_otchet : std_logic_vector(14 downto 0);

    signal cntr : std_logic_vector(8 downto 0) := (others => '0');
    signal cntr_delay : std_logic_vector(8 downto 0) := (others => '0');
    signal cntr_1 : std_logic_vector(10 downto 0) := (others => '0');
    signal cntr_2 : std_logic_vector(15 downto 0) := (others => '0');
    signal buffer_in : std_logic_vector(31 downto 0);
    signal buffer_out : std_logic_vector(31 downto 0);
    signal config : std_logic_vector(15 downto 0) := "0100110110101011";
    signal s_axis_data_tlast : std_logic := '0';
    signal s_axis_data_tvalid : std_logic := '1';
    signal m_axis_data_tready : std_logic := '0';

    signal m_axis_data_tvalid_cpy : std_logic;

    signal buf_re : std_logic_vector(15 downto 0);
    signal buf_im : std_logic_vector(15 downto 0);

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

    component complex_abs is
        Port(
            clk : in std_logic;
            data_in : in std_logic_vector(31 downto 0);
            data_out : out std_logic_vector(14 downto 0));
    end component;

    component dist_mem_gen_0 IS
        PORT (
            a : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
            d : IN STD_LOGIC_VECTOR(14 DOWNTO 0);
            dpra : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
            clk : IN STD_LOGIC;
            we : IN STD_LOGIC;
            dpo : OUT STD_LOGIC_VECTOR(14 DOWNTO 0)
            );
    END component;

begin

    buffer_in <= data_in;

    gen_tlast : process(clk) begin
        if rising_edge(clk) then
            if m_axis_data_tvalid_cpy = '1' then 
                cntr <= unsigned(cntr) + 1;
                    if cntr = "111111111" then
                        s_axis_data_tlast <= '1';
                    else
                        s_axis_data_tlast <= '0';
                    end if;
            end if;
        end if;
    end process;

    cntr_delay_proc : process(clk) begin
        if rising_edge(clk) then
            cntr_delay <= cntr;
        end if;
    end process;

    great_cntr : process(clk) begin
        if rising_edge(clk) then
            if m_axis_data_tvalid_cpy = '1' then
                cntr_2 <= unsigned(cntr_2) + 1;
            end if;
        end if;
    end process;

    gen_m_trady : process(clk) begin
        if rising_edge(clk) then
            cntr_1 <= unsigned(cntr_1) + 1;
            if cntr_1 = "10001110001" then
                m_axis_data_tready <= '1';
            end if;
        end if;
    end process;

    compare_proc : process(clk) begin
        if rising_edge(clk) then
            if unsigned(memory_dpo) < unsigned(abs_otchet) then
            --if MAXhold(conv_integer(unsigned(cntr))) < abs_otchet then
            --    MAXhold(conv_integer(unsigned(cntr))) <= abs_otchet;
                memory_d <= abs_otchet;
            else
                memory_d <= memory_dpo;
            end if;
        end if;
    end process;

    --write_proc : process(clk) begin
    --    if rising_edge(clk) then
    --        if cntr_2 > "1111111000000000" then
                data_out <= memory_dpo;
                --MAXhold(conv_integer(unsigned(cntr)));
    --        end if;
    --    end if;
    --end process;

    fft : xfft_0
    port map(
        aclk => clk,
        s_axis_config_tdata => config,
        s_axis_config_tvalid => '1',
        s_axis_config_tready => s_axis_config_tready,
        s_axis_data_tdata => buffer_in,
        s_axis_data_tvalid => '1', --s_axis_data_tvalid,
        s_axis_data_tready => s_axis_data_tready,
        s_axis_data_tlast => s_axis_data_tlast,
        m_axis_data_tdata => buffer_out,
        m_axis_data_tvalid => m_axis_data_tvalid_cpy,
        m_axis_data_tready => m_axis_data_tready, --'1',
        m_axis_data_tlast => m_axis_data_tlast,
        event_frame_started => event_frame_started,
        event_tlast_unexpected => event_tlast_unexpected,
        event_tlast_missing => event_tlast_missing,
        event_status_channel_halt => event_status_channel_halt,
        event_data_in_channel_halt => event_data_in_channel_halt,
        event_data_out_channel_halt => event_data_out_channel_halt);

    modul : complex_abs
    port map(
        clk => clk,
        data_in => buffer_out,
        data_out => abs_otchet);

    memory : dist_mem_gen_0
    port map(
        clk => clk,
        a => cntr_delay,
        dpra => cntr,
        d => memory_d,
        dpo => memory_dpo,
        we => '1');


    m_axis_data_tvalid <= m_axis_data_tvalid_cpy;

    buf_re <= buffer_out(15 downto 0);
    buf_im <= buffer_out(31 downto 16);

    --data_out <= buffer_out;

end behavioral;