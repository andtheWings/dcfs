wrangle_county_incidents_per_census_tract <- 
    function(
        county_census_pop_and_polygons_sf,
        incidents_sf
    ) {
        df1 <-
            mutate(
                county_census_pop_and_polygons_sf,
                count_incidents = 
                    lengths(
                        st_intersects(county_census_pop_and_polygons_sf, incidents_sf)
                    ),
                rate_incidents = round(count_incidents/estimate * 1000, 2)
            ) |> 
            filter(!is.na(rate_incidents))
        return(df1)
    }