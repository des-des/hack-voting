module Event.State exposing (..)

import Dict
import Event.Ports exposing (..)
import Event.Rest exposing (..)
import Event.Types exposing (..)
import Exts.RemoteData as RemoteData exposing (..)
import Firebase.Auth exposing (User)
import Json.Decode as Decode


initialVote : Vote
initialVote =
    { first = Nothing
    , second = Nothing
    , third = Nothing
    }


initialState : ( Model, Cmd Msg )
initialState =
    ( { event = Loading
      , eventError = Nothing
      , voteError = Nothing
      , projectError = Nothing
      }
    , eventListen ()
    )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ event (Decode.decodeString decodeEvent >> HeardEvent)
        , eventError EventError
        , voteSendError VoteError
        , projectSendError ProjectError
        ]


update : User -> Msg -> Model -> ( Model, Cmd Msg )
update user msg model =
    case msg of
        HeardEvent response ->
            ( { model | event = RemoteData.fromResult response }
            , Cmd.none
            )

        EventError error ->
            ( { model | eventError = Just error }
            , Cmd.none
            )

        VoteFor priority projectId ->
            case model.event of
                Success event ->
                    let
                        oldVote =
                            Dict.get user.uid event.votes
                                |> Maybe.withDefault initialVote

                        newVote =
                            case priority of
                                First ->
                                    { oldVote | first = projectId }

                                Second ->
                                    { oldVote | second = projectId }

                                Third ->
                                    { oldVote | third = projectId }
                    in
                        ( model
                        , voteSend ( user.uid, newVote )
                        )

                _ ->
                    ( model, Cmd.none )

        VoteError err ->
            ( { model | voteError = Just err }
            , Cmd.none
            )

        ProjectError err ->
            ( { model | projectError = Just err }
            , Cmd.none
            )
