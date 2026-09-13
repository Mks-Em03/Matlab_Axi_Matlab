function testbench_data_collector
% Cycle-accurate MATLAB testbench for the word-4 AXI-Stream pipeline.
% Run:  testbench_data_collector
    clc;

    vectors = { ...
        uint32([10 20 30 40 50 60 70 80 90 100]), ...
        uint32([1 2 3 4 5 6 7 8 9 10]), ...
        uint32([0 0 0 hex2dec('DEAD') 0 0 0 0 0 0]) };

    clock_mhz = 100;
    budget_us = 100;

    clear data_collector accelerator_passthrough pass_counter final_collector

    packets = 0;
    for v = 1:numel(vectors)
        vec = vectors{v};
        assert(numel(vec) == 10, 'Vector must be 10 words');
        golden = vec(4);

        first_cycle = NaN;
        out_cycle   = NaN;
        data_out    = uint32(0);

        for c = 1:24
            if c <= 10
                data_in  = vec(c);
                valid_in = true;
            else
                data_in  = uint32(0);
                valid_in = false;
            end
            if valid_in && isnan(first_cycle)
                first_cycle = c;
            end

            [word4, vec_valid] = data_collector(data_in, valid_in);
            [accel_d, accel_v] = accelerator_passthrough(word4, vec_valid);
            count              = pass_counter(vec_valid);
            [data_out, valid_out] = final_collector(accel_d, count, accel_v);

            if valid_out && isnan(out_cycle)
                out_cycle = c;
                word4_hat = bitand(data_out, uint32(65535));
                count_hat = bitshift(data_out, -16);
                packets   = packets + 1;
                assert(word4_hat == golden, 'word4 mismatch: got %u expected %u', word4_hat, golden);
                assert(count_hat == packets, 'count mismatch: got %u expected %u', count_hat, packets);
            end
        end

        assert(~isnan(out_cycle), 'No output beat for vector %d', v);
        latency_us = (out_cycle - first_cycle) / clock_mhz;
        assert(latency_us < budget_us, 'Missed 100 us budget: %.3f us', latency_us);
        fprintf('VEC %d  PASS  word4=%u  count=%u  latency=%.3f us (budget 100 us)\n', ...
            v, golden, packets, latency_us);
    end

    fprintf('All %d vectors passed.\n', numel(vectors));
end