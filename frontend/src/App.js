import logo from "./logo.svg";
import "./App.css";
import { AppBar, Button, ThemeProvider, Toolbar } from "@mui/material";

function App() {
  return (
    <div className="App">
      <ThemeProvider>
        <AppBar>
          <Toolbar>
            <Button variant="text">Investment</Button>
            <Button>Investment</Button>
          </Toolbar>
        </AppBar>
      </ThemeProvider>
    </div>
  );
}

export default App;
