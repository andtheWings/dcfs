library(targets)

sapply(
    paste0("R/", list.files("R/")),
    source
)

tar_option_set(
    packages = c(
        "dplyr", "purrr", "readr", "stringr", "tidyr",
        "leaflet", "sf"
    )
)

list(
    # Illinois County Boundaries
    tar_target(
        illinois_county_boundaries_file,
        # Downloaded on 06/25/2022 from...
        # https://hub.arcgis.com/datasets/IDOT::illinois-counties/explore
        "data/Illinois_Counties.geojson",
        format = "file"
    ),
    tar_target(
        illinois_county_boundaries,
        st_read(illinois_county_boundaries_file)
    ),
    # Hospital Addresses
    tar_target(
        hospital_addresses_raw_file,
        # From Wei Gao in email on 6/3/22
        "data/xdro_hospital_address_xy_20220603.xlsx"
    ),
    tar_target(
        hospital_addresses_raw,
        readxl::read_xlsx(hospital_addresses_raw_file)
    ),
    tar_target(
        cook_hospital_addresses,
        wrangle_county_hospital_addresses(
            hospital_addresses_raw, 
            illinois_county_boundaries,
            "cook"
        )
    ),
    tar_target(
        peoria_hospital_addresses,
        wrangle_county_hospital_addresses(
            hospital_addresses_raw, 
            illinois_county_boundaries,
            "peoria"
        )
    ),
    tar_target(
        vermilion_hospital_addresses,
        wrangle_county_hospital_addresses(
            hospital_addresses_raw, 
            illinois_county_boundaries,
            "vermilion"
        )
    ),
    # DCFS Incidents
    tar_target(
        # From Huiyuan Zhang in email on 5/20/22
        incidents_raw_file,
        "data/CookCountyHospitalDataPull811673121_XY_GEOID_TableToExcel.xlsx",
        format = "file"
    ),
    tar_target(
        incidents_raw,
        readxl::read_xlsx(incidents_raw_file)
    ),
    tar_target(
        peoria_vermilion_incidents_pre_geocode,
        wrangle_peoria_vermilion_incidents_pre_geocode(incidents_raw)
        # Sent in email to Kruti Doshi on 6/25/22
    ),
    tar_target(
        # From Kruti Doshi in email on 7/7/22
        peoria_vermilion_incidents_post_geocode_raw_file,
        "data/peoria_vermilion_incidents_post_geocode.csv",
        format = "file"
    ),
    tar_target(
        peoria_vermilion_incidents_post_geocode_raw,
        read_csv(peoria_vermilion_incidents_post_geocode_raw_file) 
    ),
    tar_target(
        incidents,
        wrangle_incidents(incidents_raw, peoria_vermilion_incidents_post_geocode_raw)
    ),
    # Tidycensus Pulls
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
        peoria_census_pop_and_polygons,
        tidycensus::get_acs(
            geography = "tract",
            variables = "B01001_001", # Total pop
            year = 2019,
            state = 17, # Illinois
            county = 143, # Peoria County
            geometry = TRUE,
            survey = "acs5"
        )
    ),
    tar_target(
        vermilion_census_pop_and_polygons,
        tidycensus::get_acs(
            geography = "tract",
            variables = "B01001_001", # Total pop
            year = 2019,
            state = 17, # Illinois
            county = 183, # Vermilion County
            geometry = TRUE,
            survey = "acs5"
        )
    ),
    # Aggregate per County
    tar_target(
        cook_incidents_per_census_tract,
        wrangle_county_incidents_per_census_tract(cook_census_pop_and_polygons, incidents)
    ),
    tar_target(
        peoria_incidents_per_census_tract,
        wrangle_county_incidents_per_census_tract(peoria_census_pop_and_polygons, incidents)
    ),
    tar_target(
        vermilion_incidents_per_census_tract,
        wrangle_county_incidents_per_census_tract(vermilion_census_pop_and_polygons, incidents)
    ),
    # Map each County
    tar_target(
        cook_dcfs_map,
        htmlwidgets::saveWidget(
            map_dcfs_incidents_by_census_tract(
                cook_incidents_per_census_tract, 
                41.816544, -87.749500, 
                "Cook"
            ),
            "widgets/cook_dcfs_map.html"
        )
    ),
    tar_target(
        peoria_dcfs_map,
        htmlwidgets::saveWidget(
            map_dcfs_incidents_by_census_tract(
                peoria_incidents_per_census_tract, 
                40.783333, -89.766667, 
                "Peoria"
            ),
            "widgets/peoria_dcfs_map.html"
        )
    ),
    tar_target(
        vermilion_dcfs_map,
        htmlwidgets::saveWidget(
            map_dcfs_incidents_by_census_tract(
                vermilion_incidents_per_census_tract, 
                40.124481, -87.630019, 
                "Vermilion"
            ),
            "widgets/vermilion_dcfs_map.html"
        )
    )
)