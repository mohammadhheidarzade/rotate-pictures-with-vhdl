USE work.types.all;
use std.textio.all;
use std.env.finish;

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY rotate_tb IS
END rotate_tb;
ARCHITECTURE behavioral OF rotate_tb IS
    -- COMPONENT rotate IS
    -- PORT (
    --     degree          :   IN     INTEGER RANGE 3 DOWNTO 0;
    --     pic_width_in    :   IN     INTEGER RANGE 50 DOWNTO 1; 
    --     pic_height_in   :   IN     INTEGER RANGE 50 DOWNTO 1;
    --     image_in        :   IN     IMAGE;

    --     pic_width_out   :   OUT    INTEGER RANGE 50 DOWNTO 1; 
    --     pic_height_out  :   OUT    INTEGER RANGE 50 DOWNTO 1;
    --     image_out       :   OUT    IMAGE  
    -- );
    -- END COMPONENT;
    -- SIGNAL degree_tb          :        INTEGER RANGE 3 DOWNTO 0;
    -- SIGNAL pic_width_in_tb    :        INTEGER RANGE 50 DOWNTO 1; 
    -- SIGNAL pic_height_in_tb   :        INTEGER RANGE 50 DOWNTO 1;
    -- SIGNAL image_in_tb        :        IMAGE;
    -- SIGNAL pic_width_out_tb   :        INTEGER RANGE 50 DOWNTO 1; 
    -- SIGNAL pic_height_out_tb  :        INTEGER RANGE 50 DOWNTO 1;
    -- SIGNAL image_out_tb       :        IMAGE  
    type header_type  is array (0 to 53) of character;
 
    type pixel_type is record
        red     : std_logic_vector(7 downto 0);
        green   : std_logic_vector(7 downto 0);
        blue    : std_logic_vector(7 downto 0);
    end record;
    
    type row_type is array (integer range <>) of pixel_type;
    type row_pointer is access row_type;
    type image_type is array (integer range <>) of row_pointer;
    type image_pointer is access image_type;

BEGIN
    -- CUT : rotate 
    -- PORT MAP (
    --     degree_tb,        
    --     pic_width_in_tb,  
    --     pic_height_in_tb, 
    --     image_in_tb,      
    --     pic_width_out_tb, 
    --     pic_height_out_tb,
    --     image_out_tb     
    -- );

    PROCESS
        TYPE char_file IS FILE OF CHARACTER;
        FILE bmp_file : char_file OPEN read_mode IS "test1.bmp";
        FILE out_file : char_file OPEN write_mode IS "out.bmp";
        VARIABLE header : header_type;
        VARIABLE image_width : INTEGER;
        VARIABLE image_height : INTEGER;
        VARIABLE row : row_pointer;
        VARIABLE image : image_pointer;
        VARIABLE padding : INTEGER;
        VARIABLE char : CHARACTER;
        VARIABLE counter : Integer;
    BEGIN
        counter := 0;

        FOR i IN header_type'RANGE LOOP
            read(bmp_file, header(i));
            counter := counter + 1;
        END LOOP;

        -- Read image width
        image_width := CHARACTER'pos(header(18)) +
        CHARACTER'pos(header(19)) * 2**8 +
        CHARACTER'pos(header(20)) * 2**16 +
        CHARACTER'pos(header(21)) * 2**24;

        -- Read image height
        image_height := CHARACTER'pos(header(22)) +
        CHARACTER'pos(header(23)) * 2**8 +
        CHARACTER'pos(header(24)) * 2**16 +
        CHARACTER'pos(header(25)) * 2**24;
        REPORT "image_width: " & INTEGER'image(image_width) &
        ", image_height: " & INTEGER'image(image_height);

        padding := (4 - image_width*3 mod 4) mod 4;
        image := new image_type(0 to image_height - 1);
        for row_i in 0 to image_height - 1 loop
            row := new row_type(0 to image_width - 1);
        
            for col_i in 0 to image_width - 1 loop
                    read(bmp_file, char);
                    counter := counter + 1;
                    row(col_i).blue :=
                    std_logic_vector(to_unsigned(character'pos(char), 8));
                    read(bmp_file, char);
                    counter := counter + 1;
                    row(col_i).green :=
                    std_logic_vector(to_unsigned(character'pos(char), 8));
                    read(bmp_file, char);
                    counter := counter + 1;
                    row(col_i).red :=
                    std_logic_vector(to_unsigned(character'pos(char), 8));
                
                end loop;
                for i in 1 to padding loop
                    read(bmp_file, char);
                    counter := counter + 1;
                end loop;
                image(row_i) := row;
        end loop;

        for i in header_type'range loop
            write(out_file, header(i));
            counter := counter - 1;
        end loop;
        for row_i in 0 to image_height - 1 loop
            row := image(row_i);
           
            for col_i in 0 to image_width - 1 loop
           
              -- Write blue pixel
              write(out_file,
                character'val(to_integer(unsigned(row(col_i).blue))));
                counter := counter - 1;
           
              -- Write green pixel
              write(out_file,
                character'val(to_integer(unsigned(row(col_i).green))));
                counter := counter - 1;
           
              -- Write red pixel
              write(out_file,
                character'val(to_integer(unsigned(row(col_i).red))));
                counter := counter - 1;
           
            end loop;
           
            deallocate(row);
           
            -- Write padding
            for i in 1 to padding loop
              write(out_file, character'val(0));
              counter := counter - 1;
            end loop;
           
        end loop;

        wait for 10 ns;

        deallocate(image);
 
        file_close(bmp_file);
        file_close(out_file);
        
        report "Simulation done. Check ""out.bmp"" image.";
        -- report counter;
        -- REPORT "image_width: " & INTEGER'image(counter);

        assert counter = 0 
        report "counter != 0 " ;
        
        assert counter > 0 
        report "counter <= 0 " ;

        assert counter > 0 
        report "counter >= 0 " ;


        

        wait;

end process;    
END behavioral ; -- arch