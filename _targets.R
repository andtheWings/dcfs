library(targets)

source("R/wrangling_incidents.R")

tar_option_set(
    packages = c(
        "dplyr", "purrr", "readr", "stringr", "tidyr",
        "leaflet", "sf"
    )
)

list(
    # DCFS Incidents
    tar_target(
        incidents_raw_file,
        "data/CookCountyHospitalDataPull811673121_XY_GEOID_TableToExcel.xlsx",
        format = "file"
    ),
    tar_target(
        incidents_raw,
        readxl::read_xlsx(incidents_raw_file)
    ),
    tar_target(
        incidents,
        wrangle_incidents(incidents_raw)
    ),
    # Tidycensus Pull
    tar_target(
        cook_census_pop_and_polygons,
        tidycensus::get_acs(
            geography = "tract",
            variables = "B01001_001", # Total pop
            year = 2019,
            state = 17, # Illinois
            county = 031, # Cook County
            geometry = TRUE,
            survey = "acs5"
        )
    ),
    tar_target(
        cook_incidents_per_census_tract,
        mutate(
            .data = cook_census_pop_and_polygons,
            count_incidents = 
                lengths(
                    st_intersects(cook_census_pop_and_polygons, incidents)
                )
        )
    )
)