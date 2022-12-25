// @flow
import React from 'react';

function renderErrors(errors, name) {
  console.log(errors)
  if (!errors) return false;

  return errors.map((error, i) =>
    <div key={i} style={{ fontSize: '85%', color: '#cc5454' }}>
      {`${error}`}
    </div>
  );
}

type Props = {
  name: string,
  errors?: any,
}

const Errors = ({ errors, name }: Props) =>
  <div>
    {renderErrors(errors, name)}
  </div>;

export default Errors;
