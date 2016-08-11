# Changelog

## 0.1.0
  - Breaking changes: see 0.0.99

## 0.0.99

  - Breaking changes:
    - Made log field in Connection private (breaking)
    - Class field excludedFields in Channel class is no longer public.
    - Connection.connect no longer returns the Socket object.
    - Connection class no longer connects for you. A connected socket must
      be passed to the constructor.
    - Packets no longer parses the payload, but just stores the bytes.
    - The Event, Response and Reply classes are no longer derived from the
      Packet class. This means that you _must_ update your listener
      type, if you use the general Packet type.
    - Notice stream of Connection object now spawns typed Notice objects, rather than Packet objects.

  - Non-breaking
  - Added utility authentication handler function
  - Branched out packet transformer to seperate library.
  - Cleaned up API documentation.

## 0.0.21

  - Made fields headerBuffer and bodyBuffer private. These were, unintentially, left public but were never intended to be exposed.
  - Closed #9 Socket Writes may cause async errors.

## 0.0.20

Breaking change release. Removed the un-dartly named functions and constants
that was deprecated in 0.0.19.

## 0.0.19-1

Patch release with documentation generated.

## 0.0.19

  - Addition of notice stream for disconnect notice
  - Deprecated most of the un-dartly named functions and constants
  - Added job-uuid parameter for bgapi
  - Minor bugfixes

## 0.0.16-beta

  - Initial beta release

