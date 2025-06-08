graph TD
    subgraph Host_Machine
        client[External Client  ]
        subgraph cities_network
            cities_app[Container: cities - port 8080]
            times_app[Container: times - port 8080]
        end
        client -->|HTTP 8080| cities_app
        cities_app -->|HTTP 8080| times_app
    end
