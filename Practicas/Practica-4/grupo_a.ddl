CREATE TABLE "public".dim_flights
(
  id BIGSERIAL
, version INTEGER
, date_from TIMESTAMP
, date_to TIMESTAMP
, pk_flight INTEGER
, flight_no VARCHAR(6)
, scheduled_departure TIMESTAMP
, scheduled_arrival TIMESTAMP
, departure_airport VARCHAR(3)
, arrival_airport VARCHAR(3)
, status VARCHAR(20)
, aircraft_code VARCHAR(3)
, actual_departure TIMESTAMP
, actual_arrival TIMESTAMP
)
;CREATE INDEX idx_dim_flights_lookup ON "public".dim_flights(pk_flight)
;
CREATE INDEX idx_dim_flights_tk ON "public".dim_flights(id)
;
