function [data_out, valid_out] = final_collector(word4, count, accel_valid)
%#codegen
% Pack {count[15:0], word4[15:0]} onto one AXI-Stream beat.
    data_out  = bitor(bitshift(uint32(count), 16), bitand(uint32(word4), uint32(65535)));
    valid_out = accel_valid;
end
