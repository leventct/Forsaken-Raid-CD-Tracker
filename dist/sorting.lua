sorting = {}
sorting.Sort = function(____, entries)
    table.sort(
        entries,
        function(a, b)
            if a.class ~= b.class then
                return a.class < b.class
            end
            if a.spellId ~= b.spellId then
                return a.spellId < b.spellId
            end
            return a.playerName < b.playerName
        end
    )
    return entries
end
RaidCD.sorting = sorting
