function pass = passTrackCut(helix1, helix2, ev, params)
    minpt   = params.minpt;
    mindpv  = params.mindpv;

    % checks that the tracks are opposite charge
    if ((helix1.curvature * helix2.curvature) > 0)
        pass = false;
        return;
    end

    % checks the parameter related to each track
    if (abs(helix1.pT()) < minpt)
        pass = false;
        return;
    elseif (abs(helix2.pT()) < minpt)
        pass = false;
        return;
    elseif (abs(helix1.dpv(ev)) < mindpv)
        pass = false;
        return;
    elseif (abs(helix2.dpv(ev)) < mindpv)
        pass = false;
        return;
    end
    
    pass = true;
end