port module Server exposing (main)

import Json.Decode as D exposing (Value)
import Platform exposing (worker)


type alias Model =
    Int


type Msg
    = Request RequestResponse


type alias RequestResponse =
    { req : Value, res : Value }


type alias RequestInfo =
    { url : String }


main =
    worker
        { init = \() -> ( 0, Cmd.none )
        , subscriptions = \_ -> onRequest Request
        , update = update
        }


port onRequest : (RequestResponse -> msg) -> Sub msg


port response : ( RequestResponse, Int, String ) -> Cmd msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg count =
    case msg of
        Request ({ req, res } as requestResponse) ->
            case decodeRequest req of
                Ok { url } ->
                    let
                        ( newCount, status, responseText ) =
                            handleRequest url count
                    in
                    ( newCount
                    , response ( requestResponse, status, responseText )
                    )

                Err err ->
                    ( count
                    , response
                        ( requestResponse
                        , 500
                        , "There was an error processing the request"
                        )
                    )


handleRequest url count =
    let
        ok () =
            ( count + 1, 200, String.fromInt count )
    in
    case url of
        "" ->
            ok ()

        "/" ->
            ok ()

        _ ->
            ( count, 404, "Not found" )


decodeRequest : Value -> Result D.Error RequestInfo
decodeRequest value =
    D.decodeValue
        (D.map RequestInfo (D.field "url" D.string))
        value
