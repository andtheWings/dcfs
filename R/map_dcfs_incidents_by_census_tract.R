map_dcfs_incidents_by_census_tract <- 
    function(
        incidents_per_census_tract_sf,
        lat_num, lng_num,
        county_char
    ) 
    {
        dcfs_palette <-
            colorNumeric(
                palette = "magma",
                domain = incidents_per_census_tract_sf$rate_incidents,
                reverse = TRUE,
            )
        
        incidents_per_census_tract_sf |> 
            st_transform(4326) |> 
            leaflet() |> 
            addProviderTiles("CartoDB.Positron") |> 
            # Center and zoom the map to Cook County
            setView(lat = lat_num, lng = lng_num, zoom = 10) |> 
            # Add button to enable fullscreen map
            leaflet.extras::addFullscreenControl() |> 
            addPolygons(
                stroke = FALSE,
                # Color according to palette above
                fillColor = ~dcfs_palette(rate_incidents),
                # Group polygons by number of deaths for use in the layer control
                group = ~ count_incidents,
                # Make slightly transparent
                fillOpacity = 0.5,
                label = "Click for more info!",
                # Click on the polygon to get info
                popup = ~ paste0(
                    "<h3>Census Tract Info:</h3>",
                    "<b>FIPS ID</b>: ", as.character(GEOID),"<br/>",
                    "<b>Count</b>: ", as.character(count_incidents), " incident(s) <br/>",
                    "<b>Population</b>: ", as.character(estimate), " people <br/>",
                    "<b>Rate</b>: ", as.character(rate_incidents), " incidents per 1,000 people"
                )
            ) |> 
            #Add legend
            addLegend(
                title = 
                    paste0(
                        "<h3>Rate of DCFS Abuse <br> or Neglect cases <br> per 1,000 people <br> in each census tract <br> of ",
                        county_char,
                        " County, IL <br> from 2016-2021</h3>"
                    ),
                values = ~ rate_incidents,
                pal = dcfs_palette,
                position = "topright"
            )
        
    }