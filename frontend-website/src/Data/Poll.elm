module Data.Poll exposing (..)


type
    Field
    -- short text input (<100 characters)
    = CharField
        { id : String
        , questionText : String
        , answer : Maybe String
        }
      -- long text input
    | TextField
        { id : String
        , questionText : String
        , answer : Maybe String
        }
      -- choice between a list of options
    | ChoiceField
        { id : String
        , questionText : String
        , choices : List String
        , selectedChoice : Maybe String
        }
      -- list of selected choices from a set of options
    | MultiChoiceField
        { id : String
        , questionText : String
        , choices : List String
        , selectedChoices : List String
        }


type alias Poll =
    { id : String
    , title : String
    , description : String
    , fields : List Field
    }


fieldId : Field -> String
fieldId field =
    case field of
        CharField { id } ->
            id

        TextField { id } ->
            id

        ChoiceField { id } ->
            id

        MultiChoiceField { id } ->
            id
