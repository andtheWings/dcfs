wrangle_county_hospital_addresses <- 
    function(
        hospital_addresses_raw_df, 
        illinois_county_boundaries_sf, 
        county_name_string
    ) {
        df1 <-
            hospital_addresses_raw_df |> 
            filter(
                st_intersects(
                    st_as_sf(
                        hospital_addresses_raw_df,
                        coords = c("X", "Y"),
                        crs = 4326
                    ),
                    filter(
                        illinois_county_boundaries_sf,
                        NAME_LC == county_name_string
                    ),
                    sparse = FALSE
                )[,1]
            )
        
        return(df1)
    }
