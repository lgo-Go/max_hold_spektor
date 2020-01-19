library IEEE;
use ieee.std_logic_arith.all;
use IEEE.STD_LOGIC_1164.ALL;
--use ieee.NUMERIC_STD.all;


entity complex_abs is
    Port(
        clk : in std_logic;
        data_in : in std_logic_vector(31 downto 0);
        data_out : out std_logic_vector(14 downto 0));
end complex_abs;


architecture Behavioral of complex_abs is

    signal a, b : std_logic_vector(15 downto 0);
    signal data_in_cpy : std_logic_vector(31 downto 0);

begin

    --data_in_cpy <= data_in;

    simple_ab : process(clk) begin
        if rising_edge(clk) then
            if signed(data_in(15 downto 0)) < 0 then
                (data_in_cpy(15 downto 0)) <= not(signed(data_in(15 downto 0)) - 1);
            end if;

            if signed(data_in(31 downto 16)) < 0 then
                (data_in_cpy(31 downto 16)) <= not(signed(data_in(31 downto 16)) - 1);
            end if;
        end if;
    end process;

    complex_ab : process (clk) begin
        if rising_edge(clk) then
            if (unsigned(data_in_cpy(15 downto 0)) > unsigned(data_in_cpy(31 downto 16))) then
                a <= (data_in_cpy(15 downto 0));
                b <= (data_in_cpy(31 downto 16));
            else
                b <= (data_in_cpy(15 downto 0));
                a <= (data_in_cpy(31 downto 16));
            end if;
        end if;
    end process;

    data_out <= ((unsigned(a(15 downto 1)) + unsigned(a(15 downto 2)) + unsigned(a(15 downto 3))) + (unsigned(b(15 downto 1))));

end Behavioral;
