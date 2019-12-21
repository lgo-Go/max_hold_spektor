library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
library std;
use std.textio.all;


entity ReadData is
    generic(
        numOfBits : integer;
        file_name : string
        );
    port(
        data: out std_logic_vector ((numOfBits-1) downto 0);
        dv: out std_logic;
        rst : in std_logic;
        rfd : in std_logic;
        clk : in std_logic
        );
end ReadData;


architecture Behavioral of ReadData is

    constant log_file_rd : string := file_name;
    file file_rd: TEXT open read_mode is log_file_rd;

begin

    read_data: process(clk, rst)
        variable s : integer;
        variable l : line;
    begin
        if (rst = '1') then
            data <= (others => '0');
            dv <= '0';
        elsif(rising_edge(clk)) then
            if rfd = '1' then
                readline(file_rd, l);
                read (l, s);
                data <= CONV_STD_LOGIC_VECTOR(s,numOfBits);
                dv <= '1';
            else
                dv <= '0';
            end if;
        end if;
    end process;

end Behavioral;
