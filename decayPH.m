function newPh = decayPh(pos, lam, del)

newPh = pos.ph*(1-lam);

if newPh < del
    newPh = 0;
end

end
