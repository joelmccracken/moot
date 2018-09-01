module Handler.Abstract where

import Import

import Handler.Auth
import Helpers.Forms
import Helpers.Handlers
import Helpers.Views

-- email address
-- twitter handle
-- phone number (Maybe)
-- country

-- previous talks given
-- URL to previous talk(s)

----- 2017 -----

-- Leap workshop, hop workshop, educational session
-- Title
-- Intro, what the talk is about
-- Relevancy. Why is this session relevant to a professional software developer?
-- Concepts. What concepts will developers learn from the session?
-- Skills. What concrete skills will developers acquire from the session?
-- Outline. Please create a brief outline how you intend to structure the session.
-- Pitch. What is the main reason developers should come to your session instead of other ones?
-- Background Requirements. If your session is on statically-typed, category-theoretic functional programming (Haskell, PureScript, Scala, etc.), please choose the category that best matches the contents of your session, such that people who are actively learning or mostly know the category contents will understand your session.
-- Note: These topic categories are based on LOFP — please see here for more details.
-- If relevant, what language(s) will you use to provide code samples?

-- Denovo
-- title
-- intro
-- Novelty. What is the core idea of your original research / novel solution?
-- Competition. What are similar or related approaches to the problem that you are solving? Citations welcome.
-- Differentiation. Why do other solutions compare unfavorably with your own work (to the extent they do)?
-- Relevancy. Why is this session relevant to a professional software developer?
-- Benefits. How will this session help developers to better accomplish their job?
-- Concepts. What concepts will developers learn from the session?
-- Skills. What concrete skills will developers acquire from the session?
-- Outline. Please create a brief outline how you intend to structure the session.
-- Pitch. What is the main reason developers should come to your session instead of other ones?
-- Background Requirements. If your session is on statically-typed, category-theoretic functional programming (Haskell, PureScript, Scala, etc.), please choose the category that best matches the contents of your session, such that people who are actively learning or mostly know the category contents will understand your session.
-- Note: These topic categories are based on LOFP — please see here for more details.
-- If relevant, what language(s) will you use to provide code samples?

-- Inspire
-- title
-- intro
-- Takeaway. What is the ONE takeaway for developers who attend your session?
-- Inspiration. In what way do you hope your session will inspire developers?
-- Entertainment. If relevant, in what way do you hope your session will entertain developers?
-- Relevancy. Why is this session relevant to a professional software developer?
-- Benefits. How will the subject matter you're covering help developers to better accomplish their job?
-- Outline. Please create a brief outline how you intend to structure the session.
-- Pitch. What is the main reason developers should come to your session instead of other ones?
-- If relevant, what language(s) will you use to provide code samples?

-- Keynote
-- title
-- intro
-- Inspiration. In what way do you hope your session will inspire developers?
-- Entertainment. If relevant, in what way do you hope your session will entertain developers?
-- Relevancy. Why is this session relevant to a professional software developer?
-- Takeaway. What is the ONE takeaway for developers who attend your session?
-- Discussion. What sorts of hallway discussions do you hope developers will have after attending your session?
-- Outline. Please create a brief outline how you intend to structure the session.
-- Pitch. What is the main reason developers should come to your session instead of other ones?
-- Background Requirements. If your session is on statically-typed, category-theoretic functional programming (Haskell, PureScript, Scala, etc.), please choose the category that best matches the contents of your session, such that people who are actively learning or mostly know the category contents will understand your session.
-- Note: These topic categories are based on LOFP — please see here for more details.
-- If relevant, what language(s) will you use to provide code samples?

----- 2016 -----

-- Title
-- Dropdown menu of topics
-- Downdown of submission type
-- Abstract summary, ~300 words
-- Relevancy. Why is this session relevant to a professional software developer?
-- Country
-- Travel assistance, checkbox: I am financially unable to speak at LambdaConf without travel assistance I would like travel assistance if it's available I do not require travel assistance to speak at LambdaConf

-- Dryfta
-- allowed you to assign roles as a primary or assistant co-author/presenter

-- Speaker + co-speaker integration

-- Form builder

-- [MVP: minimal version of the pipeline]
-- CFP collected, blind edit, blind review/rate, schedule.

-- Non-MVP follow-up questions for accepted speakers
-- Dietary preferences, kids/childcare

-- Skip dropdown toggle
-- Segment, form for a particular group
-- View all of the results submitted, blinded editor edits submissions
-- Export, or blinded reviews review in app
-- Ranking, accept or reject
-- Submitter communications/emails
-- Schedule creation

-- Pre-edit, post-edit cloak

-- Pre-edit cloaked view (committee role)
-- abstract title
-- abstract type

-- Post-edit cloaked view
-- abstract title
-- abstract proposal
-- abstract type

-- Conference cloning

data SubmittedAbstract =
  SubmittedAbstract {
    submittedAbstractSpeaker :: Text
  , submittedAbstractTitle :: Text
  , submittedAbstractBody :: Textarea
  , submittedAbstractType :: AbstractTypeId
  } deriving Show

data CreateAccount =
  CreateAccount {
    createAccountEmail :: Email
  , createAccountName :: Text
  , createAccountPassword :: Text
  } deriving Show

abstractForm :: [Entity AbstractType] -> Form SubmittedAbstract
abstractForm abstractTypes = do
  let abstractTypeList :: [(Text, AbstractTypeId)]
      abstractTypeList =
        map
        renderAbstractTypeDropdown
        abstractTypes
  renderDivs $
    SubmittedAbstract
      <$> areq textField (named "speaker-name"
                          (placeheld "Speaker's name:")) Nothing
      <*> areq textField (named "abstract-title"
                          (placeheld "Abstract title:")) Nothing
      <*> areq textareaField (named "abstract-body"
                              (placeheld "Abstract proposal:")) Nothing
      <*> areq (selectFieldList abstractTypeList)
               (named "abstract-type" (placeheld "Abstract type:")) Nothing

createAccountForm :: Form CreateAccount
createAccountForm =
  renderDivs $
    CreateAccount
      <$> areq emailField' (named "email"
                           (placeheld "Email: ")) Nothing
      <*> areq textField (named "name"
                           (placeheld "Name: ")) Nothing
      <*> areq passwordField (named "password"
                              (placeheld "Password: ")) Nothing

renderSubmitAbstract :: Entity Conference
                     -> Widget
                     -> Handler Html
renderSubmitAbstract (Entity confId Conference{..})
  submitAbstractForm = do
  welcomeMarkdown <- renderMarkdown conferenceCfpWelcome
  baseLayout Nothing $ [whamlet|
<article .grid-container>
  <div .grid-x .grid-margin-x>
    <div .medium-6 .cell>
      #{welcomeMarkdown}
      <form method="POST"
            action="@{SubmitAbstractR confId}">
        ^{submitAbstractForm}
        <input .button.success
         type="submit"
         name="submit"
         value="Submit abstract">
        <input .button
         type="submit"
         name="submit"
         formaction="@{SubmitAbstractDraftR confId}"
         value="Save draft">
      <p>
        If you submit the abstract now, that will make it the final version
        and you will not be able to make further changes. If you wish to save
        your abstract and finish writing it later, click "Save draft"
|]

getSubmitAbstractR :: ConferenceId -> Handler Html
getSubmitAbstractR conferenceId = do
  user <- requireVerifiedUser
  abstractTypes <- runDB $ getAbstractTypes conferenceId
  conf <- runDBOr404 $ get conferenceId
  (abstractWidget, _) <- generateFormPost (abstractForm abstractTypes)
  renderSubmitAbstract (Entity conferenceId conf) abstractWidget

handleSaveAbstract :: ConferenceId
                   -> Bool
                   -> Handler (Either
                               (Entity Conference, Widget)
                               (Entity Abstract))
handleSaveAbstract confId isDraft = do
  user <- requireVerifiedUser
  (conf, abstractTypes) <- runDBOr404 $ do
    maybeConf <- getConference confId
    case maybeConf of
      Nothing -> return Nothing
      (Just conf) -> do
        abstractTypes <- getAbstractTypes confId
        return $ Just $ (conf, abstractTypes)
  -- (maybeUser, createAccountWidget) <- handleCreateAccountOrLoggedIn
  ((submittedAbstract, abstractWidget), _) <- runFormPost (abstractForm abstractTypes)

  case submittedAbstract of
    FormSuccess
      (SubmittedAbstract name title body abstractTypeId) -> do
        abstract <- runDB $ do
          maybeAbstractType <- get abstractTypeId
          case maybeAbstractType of
            Nothing -> undefined
            (Just _) -> do
              insertEntity
                (Abstract
                 (entityKey user)
                 title abstractTypeId
                 (Markdown (unTextarea body)) Nothing Nothing
                 False isDraft
                )
        return $ Right abstract
    _ -> return $ Left (conf, abstractWidget)

postSubmitAbstractR :: ConferenceId -> Handler Html
postSubmitAbstractR confId = do
  abstractE <- handleSaveAbstract confId False
  case abstractE of
    (Left (conf, widget)) ->
      renderSubmitAbstract conf widget
    (Right _) ->
      redirect (SubmittedAbstractR confId)

postSubmitAbstractDraftR :: ConferenceId -> Handler Html
postSubmitAbstractDraftR confId = do
  abstractE <- handleSaveAbstract confId True
  case abstractE of
    (Left (conf, widget)) ->
      renderSubmitAbstract conf widget
    (Right abstract) ->
      redirect (AbstractDraftR confId (entityKey abstract))

getAbstractDraftR :: ConferenceId -> AbstractId -> Handler Html
getAbstractDraftR confId abstractId = undefined

postAbstractDraftR :: ConferenceId -> AbstractId -> Handler Html
postAbstractDraftR confId abstractId = undefined

getSubmittedAbstractR :: ConferenceId -> Handler Html
getSubmittedAbstractR confId = do
  _ <- runDBOr404 $ get confId
  baseLayout Nothing $ [whamlet|
<article .grid-container>
  <div .grid-x .grid-margin-x>
    <div .medium-6 .cell>
      <h3>You have successfully submitted your abstract!
      <p>
        Would you like to <a href="@{SubmitAbstractR confId}">submit another?</a>
|]
