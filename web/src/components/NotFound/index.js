// @flow
import React from 'react';
import { BrowserRouter as Link } from "react-router-dom";


const NotFound = () =>
  <div style={{ margin: '2rem auto', textAlign: 'center' }}>
    <p>Page not found</p>
    <p><Link to="/">Go to the home page →</Link></p>
  </div>;

export default NotFound;
