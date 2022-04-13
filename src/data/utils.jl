macro _load_data(const_name, force, load_data)
    quote
        if !$force && !isnothing($const_name[])
            return $const_name[]
        end
        $const_name[] = $load_data
    end |> esc
end
