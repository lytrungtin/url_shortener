// @flow
import React from 'react';

function renderMessages(messages, type) {
    
  console.log(messages);
  if (!messages) return false;
  return messages.map((message, index) => (
    <div key={index} style={{ fontSize: '85%', color: type === 'error' ? '#cc5454' : '#4caf50' }}>
      {`${message}`}
    </div>
  ));
}

type Props = {
  messages?: any,
  type: 'error' | 'success',
}

const Messages = ({ messages, type }: Props) =>
  <div>
    {renderMessages(messages, type)}
  </div>;

export default Messages;
