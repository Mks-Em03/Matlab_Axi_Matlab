function [y, y_valid] = accelerator_passthrough(u, enable)
%#codegen
% Models an Enabled Subsystem that is a pure register passthrough.
% Data updates only on enable; valid is a 1-cycle pulse (do NOT hold valid
% inside a Simulink Enabled Subsystem — held outputs would stick TVALID=1).
    persistent q
    if isempty(q)
        q = uint32(0);
    end
    if enable
        q = u;
        y_valid = true;
    else
        y_valid = false;
    end
    y = q;
end