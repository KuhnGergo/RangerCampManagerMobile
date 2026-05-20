# RangerCampManager

The flutter project for 2025-2026 graduation.

### Supported platforms:

- Android
- IOS

## Note:

The project is **not** in buildable form.

# Structure

### Core

Contains low level logic and error handling for local database and api.

### Features

presentation->action provider->repository->api, dao

dao->provider->presentation

- _api_: Calls the API with the data provided.
- _dao_: Sends or reads the data to or from the local database.
- _repository_: Cleans up the mess of _data_ for the presentation. _Data_ only contains raw functions.
- _action provider_: a special provider made for passing user inputs to _repository_. Depends on only _repositories_.
- _provider_: Manages UI state and updates UI based on the result of _provider_ or _dao_.
- _presentation_: Contains the widget tree. Reads the data from the _provider_ and sends events to the _action provider_.
