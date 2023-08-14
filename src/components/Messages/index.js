// @flow
import React from 'react';
import './index.css'
function renderMessages(messages, type) {
  if (!messages) return null;

  const copyToClipboard = (text) => {
    navigator.clipboard.writeText(text);
  };

  return messages.map((message, index) => (
    <div key={index} className={`message ${type === 'error' ? 'error' : 'success'}`}>
      <span className="message-text">{message}</span>
      <button className="copy-button" onClick={() => copyToClipboard(message)}>
        Copy
      </button>
    </div>
  ));
}

type Props = {
  messages?: any,
  type: 'error' | 'success',
}

const Messages = ({ messages, type }: Props) => (
  <div className="messages-container">
    {renderMessages(messages, type)}
  </div>
);

export default Messages;
