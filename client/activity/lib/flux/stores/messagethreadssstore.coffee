actions         = require '../actions/actiontypes'
toImmutable     = require 'app/util/toImmutable'
immutable       = require 'immutable'
KodingFluxStore = require 'app/flux/store'

###*
 * A thin data structure to hold comment list associated with given messageId.
 *
 * Comment collection is a map instead of a list, to be able to add/remove
 * things with messageId.
 *
 * @typedef {Immutable.Map} IMThread
 * @property {string} messageId
 * @property {Immutable.Map<string, string>} comments
###

###*
 * @typedef {Immutable.Map<string, IMThread>} IMThreadCollection
###
module.exports = class MessageThreadsStore extends KodingFluxStore

  @getterPath = 'MessageThreadsStore'

  getInitialState: -> immutable.Map()

  initialize: ->

    @on actions.LOAD_MESSAGE_SUCCESS, @addNewThread

    @on actions.LOAD_COMMENT_SUCCESS, @handleLoadSuccess

    @on actions.CREATE_COMMENT_BEGIN, @handleCreateBegin
    @on actions.CREATE_COMMENT_SUCCESS, @handleCreateSuccess
    @on actions.CREATE_COMMENT_FAIL, @handleCreateFail


  ###*
   * Creates a new thread if it doesn't exist.
   *
   * @param {IMThreadCollection} threads
   * @param {object} payload
   * @param {SocialMessage} message
   * @return {IMThreadCollection} nextState
  ###
  addNewThread: (threads, { message }) ->

    unless threads.has message.id
      return initThread threads, message.id

    return threads


  ###*
   * Loads comment to given message id.
   *
   * @param {IMThreadCollection} threads
   * @param {object} payload
   * @param {string} messageId
   * @param {SocialMessage} comment
   * @return {IMThreadCollection} nextState
  ###
  handleLoadSuccess: (threads, { messageId, comment }) ->

    return addComment threads, messageId, comment.id


  ###*
   * Loads fake comment to given message id.
   *
   * @param {IMThreadCollection} threads
   * @param {object} payload
   * @param {string} messageId
   * @param {string} clientRequestId
   * @return {IMThreadCollection} nextState
  ###
  handleCreateBegin: (threads, { messageId, clientRequestId }) ->

    return addComment threads, messageId, clientRequestId


  ###*
   * Loads successful comment into store, removes fake one if exists.
   *
   * @param {IMThreadCollection} threads
   * @param {object} payload
   * @param {string} payload.messageId
   * @param {string} payload.clientRequestId
   * @param {SocialMessage} payload.comment
   * @return {IMThreadCollection} nextState
  ###
  handleCreateSuccess: (threads, { messageId, clientRequestId, comment }) ->

    if clientRequestId
      threads = removeComment threads, messageId, clientRequestId

    return addComment threads, messageId, comment.id


  ###*
   * Removes fake comment from message.
   *
   * @param {IMThreadCollection} threads
   * @param {object} payload
   * @param {string} payload.messageId
   * @param {string} payload.clientRequestId
   * @return {IMThreadCollection} nextState
  ###
  handleCreateFail: (threads, { messageId, clientRequestId }) ->

    return removeComment threads, messageId, clientRequestId


###*
 * Adds given commentId to given messageId's comments list.
 * It creates the thread first if it doesn't exist.
 *
 * @param {IMThreadCollection} threads
 * @param {string} messageId
 * @param {string} commentId
 * @param {IMThreadCollection} _threads
###
addComment = (threads, messageId, commentId) ->

  unless threads.has messageId
    threads = initThread threads, messageId

  return threads.setIn [messageId, 'comments', commentId], commentId


###*
 * Removes given commentId from given messageId's comments list.
 *
 * @param {IMThreadCollection} threads
 * @param {string} messageId
 * @param {string} commentId
 * @param {IMThreadCollection} _threads
###
removeComment = (threads, messageId, commentId) ->

  return threads.removeIn [messageId, 'comments', commentId]


###*
 * Adds an empty thread for given messageId.
 *
 * @param {IMThreadCollection} threads
 * @param {string} messageId
 * @param {IMThreadCollection} _threads
###
initThread = (threads, messageId) ->

  return threads.set messageId, createThread messageId


###*
 * Creates an empty thread.
 *
 * @param {string} messageId
 * @param {IMThread} thread
###
createThread = (messageId) ->

  return toImmutable { messageId, comments: toImmutable({}) }

