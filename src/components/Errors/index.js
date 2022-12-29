// @flow
import React from 'react';

function renderErrors(errors) {
  if (!errors) return false;

  return errors.map((error) => (
    <div key={error} style={{ fontSize: '85%', color: '#cc5454' }}>
      {`${error}`}
    </div>
  ),);
}

type Props = {
  errors?: any,
}

const Errors = ({ errors }: Props) =>
  <div>
    {renderErrors(errors)}
  </div>;

export default Errors;
