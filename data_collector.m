function [word4, vec_valid] = data_collector(data_in, valid_in)
%#codegen
% Collect 10 AXI-Stream words and emit MATLAB buf(4) — the 4th word.
    persistent buf wr
    if isempty(buf)
        buf = zeros(10, 1, 'uint32');
        wr  = uint8(0);
    end

    word4    = uint32(0);
    vec_valid = false;

    if valid_in
        wr = wr + uint8(1);
        buf(wr) = data_in;
        if wr == 10
            word4    = buf(4);   % 1-based: 4th word (not buf(5), not buf[4])
            vec_valid = true;
            wr = uint8(0);
        end
    end
end