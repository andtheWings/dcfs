leaflet(cook_incident_grid) |> 
    # Use CartoDB's background tiles
    addProviderTiles("CartoDB.Positron") |> 
    # Center and zoom the map to Cook County
    setView(lat = 41.816544, lng = -87.749500, zoom = 9) |> 
    # Add button to enable fullscreen map
    leaflet.extras::addFullscreenControl() |> 
    addPolygons()


# Add census tract polygons colored to reflect the number of deaths
addPolygons(
    # No borders to the polygons, just fill
    stroke = TRUE,
    # Color according to palette above
    color = ~ .std.resid,
    # Make slightly transparent
    fillOpacity = 0.5,
    # Click on the polygon to get its ID
    popup = ~ paste0("<b>FIPS ID:</b> ", as.character(fips))
)


zips_of_interest <- c(
    # Cook County
    60000:60899, 
    # Peoria County
    61451, 61517, 61523, 61525, 61526, 
    61528, 61529, 61531, 61533, 61536, 
    61539, 61547, 61552, 61559, 61562, 
    61569, 61601, 61602, 61603, 61604, 
    61605, 61606, 61607, 61612, 61613, 
    61614, 61615, 61616, 61625, 61629, 
    61630, 61633, 61634, 61636, 61637, 
    61638, 61639, 61641, 61643, 61650, 
    61651, 61652, 61653, 61654, 61655, 
    61656,
    # Vermilion County
    60932, 60942, 60960, 60963, 61810, 
    61811, 61812, 61814, 61817, 61831, 
    61832, 61833, 61834, 61841, 61844, 
    61846, 61848, 61849, 61850, 61857, 
    61858, 61859, 61862, 61865, 61870, 
    61876, 61883
)

df <-
    raw |>
    clean_names() |>
    mutate(
        allegation_tmp = str_split(allegation, pattern = "-", n = 2),
        allegation_id = map_chr(allegation_tmp, 1),
        allegation_label = map_chr(allegation_tmp, 2),
        zip_5 = as.numeric(
            str_sub(
                string = as.character(address_zip),
                start = 1,
                end = 5
            )
        ),
        address_tmp = str_c(
            address_street1, address_city, address_state,
            sep = ", "
        ),
        address_full = str_c(
            address_tmp, zip_5,
            sep = " "
        )
    ) |>
    select(-allegation, -allegation_tmp) 

anti_join(raw, df) |>  View()

toy <- head(df, 10) 

toy_download <-
    toy |> 
    mutate_geocode(address_full)

unique(df$address_full)

library("opencage")
oc_config(
    key = Sys.getenv("OPENCAGE_KEY"),
    no_record = TRUE
)

oc_forward_df("910 Fayette Street, Indianapolis, IN 46202")