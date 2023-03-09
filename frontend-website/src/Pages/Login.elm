module Pages.Login exposing (Model, Msg, page)

import Components.Navbar exposing (navbar)
import Effect exposing (Effect)
import Gen.Params.Login exposing (Params)
import Html as H exposing (Html)
import Html.Attributes as HA
import Html.Events as HE
import Http as Http
import Json.Decode as Decode
import Json.Encode as Encode
import Page
import Request
import Shared
import View exposing (View)


page : Shared.Model -> Request.With Params -> Page.With Model Msg
page _ _ =
    Page.advanced
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- INIT


type alias LoginData =
    { username : Maybe String
    , password : Maybe String
    }


type alias Model =
    { login_data : LoginData
    , result : Maybe String
    }


encodeLoginData : { a | username : Maybe String, password : Maybe String } -> Encode.Value
encodeLoginData obj =
    -- TODO: find a better way of error handling here
    Encode.object
        [ ( "username", Maybe.withDefault "" obj.username |> Encode.string )
        , ( "password", Maybe.withDefault "" obj.password |> Encode.string )
        ]


init : ( Model, Effect Msg )
init =
    ( { login_data =
            { username = Nothing
            , password = Nothing
            }
      , result = Nothing
      }
    , Effect.none
    )



-- UPDATE


type Msg
    = UpdateUsername String
    | UpdatePassword String
    | PerformLogin
    | LoginResult String


update : Msg -> Model -> ( Model, Effect Msg )
update msg ({ login_data } as model) =
    case msg of
        UpdatePassword password ->
            let
                updated_login_data =
                    { login_data | password = Just password }
            in
            ( { model
                | login_data = updated_login_data
              }
            , Effect.none
            )

        UpdateUsername username ->
            let
                updated_login_data =
                    { login_data | username = Just username }
            in
            ( { model | login_data = updated_login_data }, Effect.none )

        PerformLogin ->
            let
                req =
                    Http.post
                        { url = "http://localhost:8000/auth/api-token/"
                        , body =
                            encodeLoginData login_data
                                |> Http.jsonBody
                        , expect = Http.expectString (Result.withDefault "" >> LoginResult)
                        }
            in
            ( model, Effect.fromCmd req )

        LoginResult res ->
            let
                _ =
                    Debug.log "" res
            in
            ( model, Effect.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> View Msg
view model =
    { title = "Poly | Login "
    , body =
        [ H.div [ HA.class "min-h-screen bg-neutral-100" ]
            [ navbar
            , login_form model
            ]
        ]
    }


login_form : Model -> Html Msg
login_form _ =
    H.div
        [ HA.class "w-4/6 mx-auto" ]
        [ H.form
            [ HA.class "flex justify-center"
            , HE.onSubmit PerformLogin
            ]
            [ H.div []
                [ H.label
                    [ HA.for "username-input" ]
                    [ H.text "Username" ]
                , H.input
                    [ HA.type_ "text"
                    , HA.class ""
                    , HA.id "username-input"
                    , HE.onInput UpdateUsername
                    ]
                    []
                ]
            , H.div []
                [ H.label
                    [ HA.for "password-input" ]
                    [ H.text "Password" ]
                , H.input
                    [ HA.type_ "password"
                    , HA.class ""
                    , HA.id "password-input"
                    , HE.onInput UpdatePassword
                    ]
                    []
                ]
            , H.input
                [ HA.type_ "submit"
                , HA.value "Login"

                -- , HE.onClick PerformLogin
                ]
                []
            ]
        ]
