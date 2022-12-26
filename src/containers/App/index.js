// @flow
import React, { Component } from 'react';
import { BrowserRouter as Router, Route, Switch } from "react-router-dom";
import Home from '../Home';
import NotFound from '../../components/NotFound';

class App extends Component {
  render() {
    return (
      <Router>
        <div>
          <Route exactly pattern="/" component={Home} />
          <Switch component={NotFound} />
        </div>
      </Router>
    );
  }
}

export default App;
