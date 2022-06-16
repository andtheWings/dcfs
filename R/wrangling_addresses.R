wrangle_cook_hospital_addresses <- function(hospital_addresses_raw_df, cook_county_boundary_sf) {
    
    df1 <-
        hospital_addresses_raw_df |> 
        filter(
            st_intersects(
                st_as_sf(
                    hospital_addresses_raw_df,
                    coords = c("X", "Y"),
                    crs = 4326
                ),
                cook_county_boundary_sf,
                sparse = FALSE
            )[,1]
        )
    
    return(df1)
    
}